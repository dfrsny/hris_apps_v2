import 'package:material_ui/material_ui.dart';
import 'package:hris_apps/features/auth/presentation/widgets/dashboard_scaffold.dart';

enum LeaveStatus { pending, approved, rejected }

extension LeaveStatusExt on LeaveStatus {
  String get label {
    switch (this) {
      case LeaveStatus.pending:
        return 'Menunggu';
      case LeaveStatus.approved:
        return 'Disetujui';
      case LeaveStatus.rejected:
        return 'Ditolak';
    }
  }

  Color get color {
    switch (this) {
      case LeaveStatus.pending:
        return Colors.orange;
      case LeaveStatus.approved:
        return Colors.green;
      case LeaveStatus.rejected:
        return Colors.red;
    }
  }
}

class AttendanceRecord {
  final String date;
  final String checkIn;
  final String checkOut;
  final String status;

  AttendanceRecord({
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
  });
}

class LeaveRequest {
  final String id;
  final String type;
  final String dateRange;
  final int days;
  final String reason;
  final LeaveStatus status;

  LeaveRequest({
    required this.id,
    required this.type,
    required this.dateRange,
    required this.days,
    required this.reason,
    required this.status,
  });
}

class PayslipRecord {
  final String period;
  final int baseSalary;
  final int allowance;
  final int deduction;

  PayslipRecord({
    required this.period,
    required this.baseSalary,
    required this.allowance,
    required this.deduction,
  });

  int get netSalary => baseSalary + allowance - deduction;
}

class EmployeeDashboardPage extends StatefulWidget {
  const EmployeeDashboardPage({
    super.key,
    required this.onLogout,
    required this.isLead,
  });

  final VoidCallback onLogout;
  final bool isLead;

  @override
  State<EmployeeDashboardPage> createState() => _EmployeeDashboardPageState();
}

class _EmployeeDashboardPageState extends State<EmployeeDashboardPage> {
  // --- State M1: Profil Pribadi ---
  final String _employeeId = 'EMP-2026-014';
  final String _fullName = 'Rizky Ramadhan';
  final String _email = 'rizky.dev@perusahaan.co.id';
  final String _department = 'Engineering';
  final String _position = 'Software Developer';
  final String _joinDate = '12 Januari 2025';
  String _phoneNumber = '081234567890';

  // --- State M3: Absensi ---
  bool _hasCheckedInToday = false;
  bool _hasCheckedOutToday = false;
  String? _todayCheckInTime;
  String? _todayCheckOutTime;

  final List<AttendanceRecord> _attendanceHistory = [
    AttendanceRecord(
      date: '25 Nov 2026',
      checkIn: '08:25',
      checkOut: '17:35',
      status: 'Tepat Waktu',
    ),
    AttendanceRecord(
      date: '24 Nov 2026',
      checkIn: '08:42',
      checkOut: '17:45',
      status: 'Terlambat',
    ),
    AttendanceRecord(
      date: '23 Nov 2026',
      checkIn: '08:19',
      checkOut: '17:30',
      status: 'Tepat Waktu',
    ),
  ];

  // --- State M4: Cuti ---
  int _remainingLeaveQuota = 9;
  final List<LeaveRequest> _leaveRequests = [
    LeaveRequest(
      id: 'LV-002',
      type: 'Cuti Tahunan',
      dateRange: '10 Des 2026 - 12 Des 2026',
      days: 3,
      reason: 'Acara keluarga di luar kota',
      status: LeaveStatus.pending,
    ),
    LeaveRequest(
      id: 'LV-001',
      type: 'Cuti Sakit',
      dateRange: '04 Nov 2026',
      days: 1,
      reason: 'Demam dan pemeriksaan dokter',
      status: LeaveStatus.approved,
    ),
  ];

  // --- State M5: Slip Gaji ---
  int _selectedPayslipIndex = 0;
  final List<PayslipRecord> _payslips = [
    PayslipRecord(
      period: 'November 2026',
      baseSalary: 8500000,
      allowance: 1250000,
      deduction: 425000,
    ),
    PayslipRecord(
      period: 'Oktober 2026',
      baseSalary: 8500000,
      allowance: 1100000,
      deduction: 425000,
    ),
    PayslipRecord(
      period: 'September 2026',
      baseSalary: 8500000,
      allowance: 1000000,
      deduction: 425000,
    ),
  ];

  String _currentTimeFormatted() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

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

  // --- Aksi M1: Edit Nomor Telepon ---
  Future<void> _showEditPhoneDialog() async {
    final formKey = GlobalKey<FormState>();
    final phoneCtrl = TextEditingController(text: _phoneNumber);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Nomor Telepon'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Nomor Telepon Aktif',
              prefixIcon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (val) {
              if (val == null || val.trim().length < 10) {
                return 'Masukkan nomor telepon yang valid (min. 10 digit)';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              // TODO: Simpan perubahan nomor telepon ke backend (M1)
              setState(() => _phoneNumber = phoneCtrl.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nomor telepon berhasil diperbarui.'),
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // --- Aksi M3: Check-In & Check-Out ---
  void _handleCheckIn() {
    final nowStr = _currentTimeFormatted();
    // TODO: Kirim data check-in ke backend (M3)
    setState(() {
      _hasCheckedInToday = true;
      _todayCheckInTime = nowStr;
      _attendanceHistory.insert(
        0,
        AttendanceRecord(
          date: 'Hari Ini (26 Nov 2026)',
          checkIn: nowStr,
          checkOut: '-',
          status: 'Hadir',
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Check-in berhasil pada pukul $nowStr.')),
    );
  }

  void _handleCheckOut() {
    final nowStr = _currentTimeFormatted();
    // TODO: Kirim data check-out ke backend (M3)
    setState(() {
      _hasCheckedOutToday = true;
      _todayCheckOutTime = nowStr;
      if (_attendanceHistory.isNotEmpty) {
        final today = _attendanceHistory.first;
        _attendanceHistory[0] = AttendanceRecord(
          date: today.date,
          checkIn: today.checkIn,
          checkOut: nowStr,
          status: 'Selesai',
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Check-out berhasil pada pukul $nowStr.')),
    );
  }

  // --- Aksi M4: Ajukan Cuti ---
  Future<void> _showCreateLeaveDialog() async {
    final formKey = GlobalKey<FormState>();
    String selectedType = 'Cuti Tahunan';
    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    DateTime endDate = DateTime.now().add(const Duration(days: 1));
    final reasonCtrl = TextEditingController();

    String fmtDate(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final totalDays = endDate.difference(startDate).inDays + 1;
          return AlertDialog(
            title: const Text('Ajukan Cuti'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Cuti',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Cuti Tahunan',
                          child: Text('Cuti Tahunan'),
                        ),
                        DropdownMenuItem(
                          value: 'Cuti Sakit',
                          child: Text('Cuti Sakit'),
                        ),
                        DropdownMenuItem(
                          value: 'Izin Khusus',
                          child: Text('Izin Khusus'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedType = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: startDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  startDate = picked;
                                  if (endDate.isBefore(startDate)) {
                                    endDate = startDate;
                                  }
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Mulai',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(fmtDate(startDate)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: endDate,
                                firstDate: startDate,
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null) {
                                setDialogState(() => endDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Selesai',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(fmtDate(endDate)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Durasi pengajuan: $totalDays hari',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: reasonCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Alasan Cuti',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'Alasan wajib diisi'
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  // TODO: Kirim pengajuan cuti ke backend (M4)
                  setState(() {
                    _leaveRequests.insert(
                      0,
                      LeaveRequest(
                        id: 'LV-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
                        type: selectedType,
                        dateRange: startDate == endDate
                            ? fmtDate(startDate)
                            : '${fmtDate(startDate)} - ${fmtDate(endDate)}',
                        days: totalDays,
                        reason: reasonCtrl.text.trim(),
                        status: LeaveStatus.pending,
                      ),
                    );
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengajuan cuti berhasil dikirim.'),
                    ),
                  );
                },
                child: const Text('Kirim Pengajuan'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      title: widget.isLead ? 'Karyawan (Lead)' : 'Karyawan',
      onLogout: widget.onLogout,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.fingerprint_outlined),
          selectedIcon: Icon(Icons.fingerprint),
          label: 'Absensi',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_note_outlined),
          selectedIcon: Icon(Icons.event_note),
          label: 'Cuti',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Slip Gaji',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
      pages: [
        _buildAttendanceTab(),
        _buildLeaveTab(),
        _buildPayslipTab(),
        _buildProfileTab(),
      ],
    );
  }

  /// Banner penanda fitur tambahan khusus Lead (M3 & M4)
  Widget _buildLeadBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.groups_outlined, size: 18, color: Colors.indigo.shade900),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Mode Team Lead: Akses pemantauan absensi tim (M3) & persetujuan cuti anggota tim (M4) aktif.',
              style: TextStyle(fontSize: 12, color: Colors.indigo.shade900),
            ),
          ),
        ],
      ),
    );
  }

  /// TAB 1: Absensi (M3)
  Widget _buildAttendanceTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.isLead) _buildLeadBanner(),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Presensi Hari Ini • Kamis, 26 Nov 2026',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeBox(
                        label: 'Jam Masuk',
                        value: _todayCheckInTime ?? '--:--',
                        icon: Icons.login,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimeBox(
                        label: 'Jam Pulang',
                        value: _todayCheckOutTime ?? '--:--',
                        icon: Icons.logout,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _hasCheckedInToday ? null : _handleCheckIn,
                        icon: const Icon(Icons.login),
                        label: const Text('Check-In'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: (!_hasCheckedInToday || _hasCheckedOutToday)
                            ? null
                            : _handleCheckOut,
                        icon: const Icon(Icons.logout),
                        label: const Text('Check-Out'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Riwayat Absensi Pribadi',
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._attendanceHistory.map(
          (item) => Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: ListTile(
              title: Text(
                item.date,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Masuk: ${item.checkIn}  •  Pulang: ${item.checkOut}',
              ),
              trailing: Chip(
                label: Text(item.status, style: const TextStyle(fontSize: 12)),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// TAB 2: Ajukan Cuti (M4)
  Widget _buildLeaveTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isLead) _buildLeadBanner(),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengajuan Cuti Saya',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Sisa kuota cuti tahunan: $_remainingLeaveQuota hari',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: _showCreateLeaveDialog,
                icon: const Icon(Icons.add),
                label: const Text('Ajukan Cuti'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _leaveRequests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final req = _leaveRequests[index];
                return Card(
                  elevation: 0,
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
                              '${req.type} (${req.days} hari)',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: req.status.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                req.status.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: req.status.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          req.dateRange,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        Text(req.reason),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// TAB 3: Slip Gaji (M5)
  Widget _buildPayslipTab() {
    final currentSlip = _payslips[_selectedPayslipIndex];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<int>(
          value: _selectedPayslipIndex,
          decoration: const InputDecoration(
            labelText: 'Pilih Periode Penggajian',
            prefixIcon: Icon(Icons.calendar_month_outlined),
            border: OutlineInputBorder(),
          ),
          items: List.generate(_payslips.length, (i) {
            return DropdownMenuItem(value: i, child: Text(_payslips[i].period));
          }),
          onChanged: (val) {
            if (val != null) setState(() => _selectedPayslipIndex = val);
          },
        ),
        const SizedBox(height: 16),
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
                  'Slip Gaji • ${currentSlip.period}',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$_fullName ($_employeeId)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Divider(height: 24),
                _buildSalaryRow(
                  'Gaji Pokok',
                  _formatRupiah(currentSlip.baseSalary),
                ),
                const SizedBox(height: 8),
                _buildSalaryRow(
                  'Tunjangan',
                  _formatRupiah(currentSlip.allowance),
                ),
                const SizedBox(height: 8),
                _buildSalaryRow(
                  'Potongan (BPJS & Pajak)',
                  '- ${_formatRupiah(currentSlip.deduction)}',
                  valueColor: Colors.red.shade700,
                ),
                const Divider(height: 24),
                _buildSalaryRow(
                  'Total Gaji Bersih (Take Home Pay)',
                  _formatRupiah(currentSlip.netSalary),
                  isTotal: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSalaryRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 15 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 16 : 14,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  /// TAB 4: Profil Pribadi (M1)
  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      child: Text(
                        _fullName[0],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fullName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text('$_position • $_department'),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),
                _buildProfileItem('ID Karyawan', _employeeId),
                _buildProfileItem('Email Kantor', _email),
                _buildProfileItem('Departemen', _department),
                _buildProfileItem('Jabatan', _position),
                _buildProfileItem('Tanggal Bergabung', _joinDate),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildProfileItem('Nomor Telepon', _phoneNumber),
                    ),
                    OutlinedButton.icon(
                      onPressed: _showEditPhoneDialog,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Ubah'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
