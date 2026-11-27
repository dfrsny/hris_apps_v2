import 'package:material_ui/material_ui.dart';
import 'package:hris_apps/features/auth/presentation/widgets/dashboard_scaffold.dart';

enum PayrollStatus { draft, processed, finalized }

extension PayrollStatusExt on PayrollStatus {
  String get label {
    switch (this) {
      case PayrollStatus.draft:
        return 'Belum Diproses';
      case PayrollStatus.processed:
        return 'Selesai Diproses';
      case PayrollStatus.finalized:
        return 'Terkunci (Final)';
    }
  }

  Color get color {
    switch (this) {
      case PayrollStatus.draft:
        return Colors.orange;
      case PayrollStatus.processed:
        return Colors.blue;
      case PayrollStatus.finalized:
        return Colors.green;
    }
  }
}

class AttendanceDepartmentSummary {
  final String department;
  final int activeEmployees;
  final int totalWorkDays;
  final int totalLateCount;
  final int totalUnpaidLeaveDays;

  AttendanceDepartmentSummary({
    required this.department,
    required this.activeEmployees,
    required this.totalWorkDays,
    required this.totalLateCount,
    required this.totalUnpaidLeaveDays,
  });
}

class DepartmentPayrollSummary {
  final String department;
  final int employeeCount;
  final int totalBaseSalary;
  final int totalAllowance;
  final int totalDeduction;

  DepartmentPayrollSummary({
    required this.department,
    required this.employeeCount,
    required this.totalBaseSalary,
    required this.totalAllowance,
    required this.totalDeduction,
  });

  int get totalNetPayout => totalBaseSalary + totalAllowance - totalDeduction;
}

class MonthlyPayrollBatch {
  final String period;
  PayrollStatus status;
  String? processedAt;
  final List<AttendanceDepartmentSummary> attendanceSummaries;
  final List<DepartmentPayrollSummary> departmentPayrolls;

  MonthlyPayrollBatch({
    required this.period,
    required this.status,
    this.processedAt,
    required this.attendanceSummaries,
    required this.departmentPayrolls,
  });

  int get totalEmployees =>
      departmentPayrolls.fold(0, (sum, d) => sum + d.employeeCount);

  int get grandTotalGross => departmentPayrolls.fold(
    0,
    (sum, d) => sum + d.totalBaseSalary + d.totalAllowance,
  );

  int get grandTotalDeduction =>
      departmentPayrolls.fold(0, (sum, d) => sum + d.totalDeduction);

  int get grandTotalNet =>
      departmentPayrolls.fold(0, (sum, d) => sum + d.totalNetPayout);
}

class FinanceDashboardPage extends StatefulWidget {
  const FinanceDashboardPage({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<FinanceDashboardPage> createState() => _FinanceDashboardPageState();
}

class _FinanceDashboardPageState extends State<FinanceDashboardPage> {
  int _selectedPeriodIndex = 0;
  bool _isRunningPayroll = false;

  // Data agregat per periode (tanpa data pribadi karyawan, tanpa baris absensi mentah)
  final List<MonthlyPayrollBatch> _batches = [
    MonthlyPayrollBatch(
      period: 'November 2026',
      status: PayrollStatus.draft,
      attendanceSummaries: [
        AttendanceDepartmentSummary(
          department: 'Engineering',
          activeEmployees: 18,
          totalWorkDays: 392,
          totalLateCount: 7,
          totalUnpaidLeaveDays: 1,
        ),
        AttendanceDepartmentSummary(
          department: 'Operations & Support',
          activeEmployees: 14,
          totalWorkDays: 306,
          totalLateCount: 5,
          totalUnpaidLeaveDays: 2,
        ),
        AttendanceDepartmentSummary(
          department: 'Marketing & Sales',
          activeEmployees: 10,
          totalWorkDays: 218,
          totalLateCount: 4,
          totalUnpaidLeaveDays: 0,
        ),
        AttendanceDepartmentSummary(
          department: 'HR & Finance',
          activeEmployees: 6,
          totalWorkDays: 132,
          totalLateCount: 1,
          totalUnpaidLeaveDays: 0,
        ),
      ],
      departmentPayrolls: [
        DepartmentPayrollSummary(
          department: 'Engineering',
          employeeCount: 18,
          totalBaseSalary: 162000000,
          totalAllowance: 22500000,
          totalDeduction: 8100000,
        ),
        DepartmentPayrollSummary(
          department: 'Operations & Support',
          employeeCount: 14,
          totalBaseSalary: 91000000,
          totalAllowance: 14000000,
          totalDeduction: 4550000,
        ),
        DepartmentPayrollSummary(
          department: 'Marketing & Sales',
          employeeCount: 10,
          totalBaseSalary: 72000000,
          totalAllowance: 15000000,
          totalDeduction: 3600000,
        ),
        DepartmentPayrollSummary(
          department: 'HR & Finance',
          employeeCount: 6,
          totalBaseSalary: 48000000,
          totalAllowance: 7200000,
          totalDeduction: 2400000,
        ),
      ],
    ),
    MonthlyPayrollBatch(
      period: 'Oktober 2026',
      status: PayrollStatus.finalized,
      processedAt: '28 Okt 2026, 14:20',
      attendanceSummaries: [
        AttendanceDepartmentSummary(
          department: 'Engineering',
          activeEmployees: 18,
          totalWorkDays: 396,
          totalLateCount: 4,
          totalUnpaidLeaveDays: 0,
        ),
        AttendanceDepartmentSummary(
          department: 'Operations & Support',
          activeEmployees: 14,
          totalWorkDays: 308,
          totalLateCount: 6,
          totalUnpaidLeaveDays: 1,
        ),
        AttendanceDepartmentSummary(
          department: 'Marketing & Sales',
          activeEmployees: 10,
          totalWorkDays: 220,
          totalLateCount: 2,
          totalUnpaidLeaveDays: 0,
        ),
        AttendanceDepartmentSummary(
          department: 'HR & Finance',
          activeEmployees: 6,
          totalWorkDays: 132,
          totalLateCount: 0,
          totalUnpaidLeaveDays: 0,
        ),
      ],
      departmentPayrolls: [
        DepartmentPayrollSummary(
          department: 'Engineering',
          employeeCount: 18,
          totalBaseSalary: 162000000,
          totalAllowance: 21600000,
          totalDeduction: 8100000,
        ),
        DepartmentPayrollSummary(
          department: 'Operations & Support',
          employeeCount: 14,
          totalBaseSalary: 91000000,
          totalAllowance: 13800000,
          totalDeduction: 4550000,
        ),
        DepartmentPayrollSummary(
          department: 'Marketing & Sales',
          employeeCount: 10,
          totalBaseSalary: 72000000,
          totalAllowance: 14500000,
          totalDeduction: 3600000,
        ),
        DepartmentPayrollSummary(
          department: 'HR & Finance',
          employeeCount: 6,
          totalBaseSalary: 48000000,
          totalAllowance: 7200000,
          totalDeduction: 2400000,
        ),
      ],
    ),
  ];

  MonthlyPayrollBatch get _currentBatch => _batches[_selectedPeriodIndex];

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return 'Rp $buffer';
  }

  Future<void> _runPayrollForPeriod() async {
    final batch = _currentBatch;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Jalankan Proses Payroll'),
        content: Text(
          'Sistem akan menghitung payroll bulanan periode ${batch.period} untuk ${batch.totalEmployees} karyawan berdasarkan rekap absensi M3 dan membuat laporan ringkasan.\n\nLanjutkan proses?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Jalankan Payroll'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isRunningPayroll = true);

    // TODO: Panggil backend/RPC untuk eksekusi kalkulasi payroll bulanan M5
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;
    setState(() {
      batch.status = PayrollStatus.processed;
      batch.processedAt = '26 Nov 2026, 23:55';
      _isRunningPayroll = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payroll periode ${batch.period} selesai diproses & laporan dibuat.',
        ),
      ),
    );
  }

  void _finalizePayroll() {
    setState(() {
      _currentBatch.status = PayrollStatus.finalized;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Laporan payroll ${_currentBatch.period} telah dikunci (Final).',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      title: 'Finance',
      onLogout: widget.onLogout,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.summarize_outlined),
          selectedIcon: Icon(Icons.summarize),
          label: 'Absensi',
        ),
        NavigationDestination(
          icon: Icon(Icons.payments_outlined),
          selectedIcon: Icon(Icons.payments),
          label: 'Proses',
        ),
        NavigationDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics),
          label: 'Laporan',
        ),
      ],
      pages: [
        _buildAttendanceSummaryTab(),
        _buildPayrollProcessTab(),
        _buildPayrollReportTab(),
      ],
    );
  }

  Widget _buildScopeNoticeBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, size: 18, color: Colors.teal.shade900),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Akses Agregat Finance: Hanya menampilkan ringkasan rekapitulasi & laporan payroll. Baris absensi mentah, data pribadi karyawan, struktur tim, dan pengaturan sistem tidak tersedia.',
              style: TextStyle(fontSize: 12, color: Colors.teal.shade900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelectorCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _selectedPeriodIndex,
              isDense: true,
              decoration: const InputDecoration(
                labelText: 'Periode Bulanan',
                prefixIcon: Icon(Icons.calendar_month_outlined),
                border: OutlineInputBorder(),
              ),
              items: List.generate(_batches.length, (i) {
                return DropdownMenuItem(
                  value: i,
                  child: Text(_batches[i].period),
                );
              }),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedPeriodIndex = val);
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _currentBatch.status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _currentBatch.status.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _currentBatch.status.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// TAB 1: Rekap Absensi (M3)
  Widget _buildAttendanceSummaryTab() {
    final summaries = _currentBatch.attendanceSummaries;
    final totalEmployees = summaries.fold(
      0,
      (sum, item) => sum + item.activeEmployees,
    );
    final totalWorkDays = summaries.fold(
      0,
      (sum, item) => sum + item.totalWorkDays,
    );
    final totalLate = summaries.fold(
      0,
      (sum, item) => sum + item.totalLateCount,
    );
    final totalUnpaidLeave = summaries.fold(
      0,
      (sum, item) => sum + item.totalUnpaidLeaveDays,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildScopeNoticeBanner(),
        _buildPeriodSelectorCard(),
        Text(
          'Ringkasan Kehadiran Periode ${_currentBatch.period}',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Data agregat untuk komponen kalkulasi payroll (tidak memuat log jam masuk/pulang harian individu).',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Karyawan Aktif',
                value: '$totalEmployees',
                icon: Icons.people_outline,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'Total Hari Kerja',
                value: '$totalWorkDays hr',
                icon: Icons.event_available_outlined,
                color: Colors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Total Keterlambatan',
                value: '$totalLate kali',
                icon: Icons.schedule_outlined,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'Cuti Tanpa Upah',
                value: '$totalUnpaidLeave hr',
                icon: Icons.event_busy_outlined,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Rekapitulasi per Departemen',
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...summaries.map(
          (dept) => Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dept.department,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${dept.activeEmployees} karyawan',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Hari Hadir: ${dept.totalWorkDays}'),
                      Text('Terlambat: ${dept.totalLateCount}x'),
                      Text('Unpaid Leave: ${dept.totalUnpaidLeaveDays} hr'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// TAB 2: Proses Payroll (M5)
  Widget _buildPayrollProcessTab() {
    final batch = _currentBatch;
    final isLocked = batch.status == PayrollStatus.finalized;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPeriodSelectorCard(),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Eksekusi Payroll • ${batch.period}',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  batch.processedAt != null
                      ? 'Terakhir diproses: ${batch.processedAt}'
                      : 'Menunggu eksekusi kalkulasi bulanan.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Divider(height: 24),
                _buildSummaryLine(
                  'Jumlah Karyawan Terhitung',
                  '${batch.totalEmployees} orang',
                ),
                const SizedBox(height: 8),
                _buildSummaryLine(
                  'Total Gaji Kotor & Tunjangan',
                  _formatRupiah(batch.grandTotalGross),
                ),
                const SizedBox(height: 8),
                _buildSummaryLine(
                  'Total Potongan (BPJS, Pajak, Absensi)',
                  '- ${_formatRupiah(batch.grandTotalDeduction)}',
                  valueColor: Colors.red.shade700,
                ),
                const Divider(height: 24),
                _buildSummaryLine(
                  'Total Pengeluaran Gaji Bersih',
                  _formatRupiah(batch.grandTotalNet),
                  isBold: true,
                ),
                const SizedBox(height: 20),
                if (!isLocked)
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isRunningPayroll
                              ? null
                              : _runPayrollForPeriod,
                          icon: _isRunningPayroll
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.play_arrow_rounded),
                          label: Text(
                            batch.status == PayrollStatus.draft
                                ? 'Proses Payroll'
                                : 'Hitung Ulang Payroll',
                          ),
                        ),
                      ),
                      if (batch.status == PayrollStatus.processed) ...[
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _finalizePayroll,
                          icon: const Icon(Icons.lock_outline),
                          label: const Text('Kunci Laporan'),
                        ),
                      ],
                    ],
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green.shade800,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Payroll periode ${batch.period} telah difinalisasi dan laporan siap diunduh pada menu Laporan.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// TAB 3: Laporan Payroll (M5)
  Widget _buildPayrollReportTab() {
    final batch = _currentBatch;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPeriodSelectorCard(),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Laporan Payroll • ${batch.period}',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Ringkasan distribusi biaya gaji per departemen',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: batch.status == PayrollStatus.draft
                  ? null
                  : () {
                      // TODO: Ekspor/unduh laporan ringkasan payroll periode (CSV/PDF)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Mengunduh laporan ringkasan payroll ${batch.period}...',
                          ),
                        ),
                      );
                    },
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Unduh Laporan'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.primaryContainer
              .withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ringkasan Periode ${batch.period}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildSummaryLine(
                  'Total Karyawan',
                  '${batch.totalEmployees} orang',
                ),
                const SizedBox(height: 6),
                _buildSummaryLine(
                  'Total Bruto',
                  _formatRupiah(batch.grandTotalGross),
                ),
                const SizedBox(height: 6),
                _buildSummaryLine(
                  'Total Potongan',
                  _formatRupiah(batch.grandTotalDeduction),
                ),
                const Divider(height: 18),
                _buildSummaryLine(
                  'Total Netto Dibayarkan',
                  _formatRupiah(batch.grandTotalNet),
                  isBold: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Rincian per Departemen',
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...batch.departmentPayrolls.map(
          (dept) => Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dept.department,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Chip(
                        label: Text(
                          '${dept.employeeCount} orang',
                          style: const TextStyle(fontSize: 12),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  _buildSummaryLine(
                    'Total Gaji Pokok',
                    _formatRupiah(dept.totalBaseSalary),
                  ),
                  const SizedBox(height: 4),
                  _buildSummaryLine(
                    'Total Tunjangan',
                    _formatRupiah(dept.totalAllowance),
                  ),
                  const SizedBox(height: 4),
                  _buildSummaryLine(
                    'Total Potongan',
                    '- ${_formatRupiah(dept.totalDeduction)}',
                    valueColor: Colors.red.shade700,
                  ),
                  const Divider(height: 16),
                  _buildSummaryLine(
                    'Subtotal Departemen',
                    _formatRupiah(dept.totalNetPayout),
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
