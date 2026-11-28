import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hris_apps/features/finance/data/models/attendance_department_summary_model.dart';
import 'package:hris_apps/features/finance/data/models/department_payroll_summary_model.dart';
import 'package:hris_apps/features/finance/data/models/monthly_payroll_batch_model.dart';
import 'package:hris_apps/features/finance/domain/entities/monthly_payroll_batch.dart';

abstract class FinanceRemoteDataSource {
  Future<List<MonthlyPayrollBatchModel>> fetchPayrollBatches();
  Future<MonthlyPayrollBatchModel> executePayrollBatch(String period);
  Future<MonthlyPayrollBatchModel> lockPayrollBatch(String period);
}

class FinanceRemoteDataSourceImpl implements FinanceRemoteDataSource {
  final SupabaseClient _supabase;

  FinanceRemoteDataSourceImpl({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  static const List<String> _monthsId = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  /// Mengubah DateTime menjadi string periode (contoh: "November 2026")
  String _formatPeriod(DateTime date) =>
      '${_monthsId[date.month - 1]} ${date.year}';

  /// Mengubah string periode (contoh: "November 2026") menjadi (year, month)
  ({int year, int month}) _parsePeriod(String period) {
    final parts = period.trim().split(' ');
    if (parts.length == 2) {
      final monthIdx = _monthsId.indexWhere(
        (m) => m.toLowerCase() == parts[0].toLowerCase(),
      );
      final year = int.tryParse(parts[1]);
      if (monthIdx != -1 && year != null) {
        return (year: year, month: monthIdx + 1);
      }
    }
    final now = DateTime.now();
    return (year: now.year, month: now.month);
  }

  String _formatTimestamp(String? iso) {
    if (iso == null) return '-';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return iso;
    const shortMonths = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final mon = shortMonths[dt.month - 1];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$day $mon ${dt.year}, $h:$m';
  }

  PayrollStatus _parseStatus(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'processed':
        return PayrollStatus.processed;
      case 'finalized':
        return PayrollStatus.finalized;
      case 'draft':
      default:
        return PayrollStatus.draft;
    }
  }

  /// Membangun rekap presensi & gaji per departemen untuk satu periode bulan
  Future<MonthlyPayrollBatchModel> _buildBatchForPeriod({
    required String period,
    required PayrollStatus status,
    String? processedAt,
    required List<Map<String, dynamic>> activeProfiles,
  }) async {
    final parsed = _parsePeriod(period);
    final startDate =
        '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-01';
    final nextMonth = parsed.month == 12
        ? DateTime(parsed.year + 1, 1, 1)
        : DateTime(parsed.year, parsed.month + 1, 1);
    final endDate =
        '${nextMonth.year}-${nextMonth.month.toString().padLeft(2, '0')}-01';

    // 1. Ambil log absensi pada periode bulan tersebut
    final attendanceRows = await _supabase
        .from('attendances')
        .select('user_id, status')
        .gte('attendance_date', startDate)
        .lt('attendance_date', endDate);

    // 2. Ambil cuti yang disetujui untuk menghitung cuti tidak dibayar (unpaid leave)
    final leaveRows = await _supabase
        .from('leave_requests')
        .select('user_id, leave_type, days, date_range')
        .eq('status', 'approved');

    // 3. Jika sudah processed/finalized, ambil angka historis aktual dari tabel payslips
    final Map<String, Map<String, dynamic>> payslipByUser = {};
    if (status != PayrollStatus.draft) {
      final slipRows = await _supabase
          .from('payslips')
          .select('user_id, base_salary, allowance, deduction')
          .eq('period', period);
      for (final s in (slipRows as List<dynamic>)) {
        final m = s as Map<String, dynamic>;
        payslipByUser[m['user_id'] as String] = m;
      }
    }

    // Petakan departemen tiap user
    final Map<String, String> deptByUserId = {};
    final Set<String> departments = {};
    for (final p in activeProfiles) {
      final id = p['id'] as String;
      final dept = (p['department'] as String?)?.trim().isNotEmpty == true
          ? (p['department'] as String).trim()
          : 'Umum';
      deptByUserId[id] = dept;
      departments.add(dept);
    }

    // Hitung statistik absensi per departemen
    final Map<String, int> workDaysByDept = {};
    final Map<String, int> lateCountByDept = {};
    for (final a in (attendanceRows as List<dynamic>)) {
      final map = a as Map<String, dynamic>;
      final uid = map['user_id'] as String?;
      final dept = uid != null ? deptByUserId[uid] : null;
      if (dept == null) continue;

      workDaysByDept[dept] = (workDaysByDept[dept] ?? 0) + 1;
      final st = (map['status'] as String? ?? '').toLowerCase();
      if (st.contains('terlambat')) {
        lateCountByDept[dept] = (lateCountByDept[dept] ?? 0) + 1;
      }
    }

    // Hitung unpaid leave per departemen
    final Map<String, int> unpaidDaysByDept = {};
    for (final l in (leaveRows as List<dynamic>)) {
      final map = l as Map<String, dynamic>;
      final uid = map['user_id'] as String?;
      final dept = uid != null ? deptByUserId[uid] : null;
      if (dept == null) continue;

      final leaveType = (map['leave_type'] as String? ?? '').toLowerCase();
      final dateRange = (map['date_range'] as String? ?? '').toLowerCase();
      final shortMonth = _monthsId[parsed.month - 1]
          .substring(0, 3)
          .toLowerCase();
      final isMatchingMonth =
          dateRange.contains(shortMonth) &&
          dateRange.contains('${parsed.year}');

      if (isMatchingMonth &&
          (leaveType.contains('tidak dibayar') ||
              leaveType.contains('unpaid') ||
              leaveType.contains('izin'))) {
        final days = (map['days'] as num?)?.toInt() ?? 0;
        unpaidDaysByDept[dept] = (unpaidDaysByDept[dept] ?? 0) + days;
      }
    }

    // Susun list ringkasan per departemen
    final sortedDepts = departments.toList()..sort();
    final List<AttendanceDepartmentSummaryModel> attendanceSummaries = [];
    final List<DepartmentPayrollSummaryModel> departmentPayrolls = [];

    for (final dept in sortedDepts) {
      final deptEmployees = activeProfiles.where((p) {
        final d = (p['department'] as String?)?.trim().isNotEmpty == true
            ? (p['department'] as String).trim()
            : 'Umum';
        return d == dept;
      }).toList();

      int totalBase = 0;
      int totalAllowance = 0;
      int totalDeduction = 0;

      for (final emp in deptEmployees) {
        final uid = emp['id'] as String;
        final source = payslipByUser[uid] ?? emp;
        totalBase += (source['base_salary'] as num?)?.toInt() ?? 0;
        totalAllowance += (source['allowance'] as num?)?.toInt() ?? 0;
        totalDeduction += (source['deduction'] as num?)?.toInt() ?? 0;
      }

      attendanceSummaries.add(
        AttendanceDepartmentSummaryModel(
          department: dept,
          activeEmployees: deptEmployees.length,
          totalWorkDays: workDaysByDept[dept] ?? 0,
          totalLateCount: lateCountByDept[dept] ?? 0,
          totalUnpaidLeaveDays: unpaidDaysByDept[dept] ?? 0,
        ),
      );

      departmentPayrolls.add(
        DepartmentPayrollSummaryModel(
          department: dept,
          employeeCount: deptEmployees.length,
          totalBaseSalary: totalBase,
          totalAllowance: totalAllowance,
          totalDeduction: totalDeduction,
        ),
      );
    }

    return MonthlyPayrollBatchModel(
      period: period,
      status: status,
      processedAt: processedAt,
      attendanceSummaries: attendanceSummaries,
      departmentPayrolls: departmentPayrolls,
    );
  }

  @override
  Future<List<MonthlyPayrollBatchModel>> fetchPayrollBatches() async {
    try {
      // 1. Ambil semua karyawan aktif (selain super_admin)
      final profilesRes = await _supabase
          .from('profiles')
          .select('id, department, base_salary, allowance, deduction')
          .eq('is_active', true)
          .neq('role', 'super_admin');

      final activeProfiles = (profilesRes as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      // 2. Ambil daftar batch yang sudah tersimpan di payroll_batches
      final batchesRes = await _supabase
          .from('payroll_batches')
          .select('period, status, processed_at')
          .order('created_at', ascending: false);

      final existingBatches = (batchesRes as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      // 3. Pastikan periode bulan berjalan & bulan sebelumnya selalu tersedia
      final now = DateTime.now();
      final currentPeriod = _formatPeriod(now);
      final prevMonthDate = DateTime(now.year, now.month - 1, 1);
      final prevPeriod = _formatPeriod(prevMonthDate);

      final Map<String, Map<String, dynamic>> batchMap = {
        for (final b in existingBatches) b['period'] as String: b,
      };

      if (!batchMap.containsKey(currentPeriod)) {
        batchMap[currentPeriod] = {
          'period': currentPeriod,
          'status': 'draft',
          'processed_at': null,
        };
      }
      if (!batchMap.containsKey(prevPeriod)) {
        batchMap[prevPeriod] = {
          'period': prevPeriod,
          'status': 'draft',
          'processed_at': null,
        };
      }

      // Urutkan periode terbaru di atas
      final sortedPeriods = batchMap.keys.toList()
        ..sort((a, b) {
          final pa = _parsePeriod(a);
          final pb = _parsePeriod(b);
          final cmpYear = pb.year.compareTo(pa.year);
          return cmpYear != 0 ? cmpYear : pb.month.compareTo(pa.month);
        });

      final List<MonthlyPayrollBatchModel> results = [];
      for (final period in sortedPeriods) {
        final meta = batchMap[period]!;
        final batch = await _buildBatchForPeriod(
          period: period,
          status: _parseStatus(meta['status'] as String?),
          processedAt: meta['processed_at'] != null
              ? _formatTimestamp(meta['processed_at'].toString())
              : null,
          activeProfiles: activeProfiles,
        );
        results.add(batch);
      }

      return results;
    } on PostgrestException catch (e) {
      throw Exception('Gagal memuat data payroll: ${e.message}');
    }
  }

  @override
  Future<MonthlyPayrollBatchModel> executePayrollBatch(String period) async {
    try {
      // 1. Cek apakah batch sudah terkunci (finalized)
      final existing = await _supabase
          .from('payroll_batches')
          .select('status')
          .eq('period', period)
          .maybeSingle();

      if (existing != null && existing['status'] == 'finalized') {
        throw Exception('Payroll periode $period sudah dikunci (finalized).');
      }

      // 2. Ambil seluruh karyawan aktif untuk diterbitkan slip gajinya
      final profilesRes = await _supabase
          .from('profiles')
          .select('id, department, base_salary, allowance, deduction')
          .eq('is_active', true)
          .neq('role', 'super_admin');

      final activeProfiles = (profilesRes as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      // 3. Terbitkan / perbarui baris slip gaji di tabel payslips untuk tiap karyawan
      if (activeProfiles.isNotEmpty) {
        final payslipRows = activeProfiles.map((emp) {
          return {
            'user_id': emp['id'] as String,
            'period': period,
            'base_salary': (emp['base_salary'] as num?)?.toInt() ?? 0,
            'allowance': (emp['allowance'] as num?)?.toInt() ?? 0,
            'deduction': (emp['deduction'] as num?)?.toInt() ?? 0,
          };
        }).toList();

        await _supabase
            .from('payslips')
            .upsert(payslipRows, onConflict: 'user_id,period');
      }

      // 4. Simpan status batch sebagai 'processed'
      final nowIso = DateTime.now().toUtc().toIso8601String();
      await _supabase.from('payroll_batches').upsert({
        'period': period,
        'status': 'processed',
        'processed_at': nowIso,
      });

      return await _buildBatchForPeriod(
        period: period,
        status: PayrollStatus.processed,
        processedAt: _formatTimestamp(nowIso),
        activeProfiles: activeProfiles,
      );
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengeksekusi payroll: ${e.message}');
    }
  }

  @override
  Future<MonthlyPayrollBatchModel> lockPayrollBatch(String period) async {
    try {
      final updated = await _supabase
          .from('payroll_batches')
          .update({'status': 'finalized'})
          .eq('period', period)
          .select('period, status, processed_at')
          .single();

      final profilesRes = await _supabase
          .from('profiles')
          .select('id, department, base_salary, allowance, deduction')
          .eq('is_active', true)
          .neq('role', 'super_admin');

      final activeProfiles = (profilesRes as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      return await _buildBatchForPeriod(
        period: period,
        status: PayrollStatus.finalized,
        processedAt: updated['processed_at'] != null
            ? _formatTimestamp(updated['processed_at'].toString())
            : null,
        activeProfiles: activeProfiles,
      );
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengunci batch payroll: ${e.message}');
    }
  }
}
