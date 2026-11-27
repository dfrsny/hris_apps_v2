import 'package:material_ui/material_ui.dart';
import 'package:hris_apps/features/auth/presentation/widgets/dashboard_scaffold.dart';

enum LeaveApprovalStatus { pending, approved, rejected }

extension LeaveApprovalStatusExt on LeaveApprovalStatus {
  String get label {
    switch (this) {
      case LeaveApprovalStatus.pending:
        return 'Menunggu';
      case LeaveApprovalStatus.approved:
        return 'Disetujui';
      case LeaveApprovalStatus.rejected:
        return 'Ditolak';
    }
  }

  Color get color {
    switch (this) {
      case LeaveApprovalStatus.pending:
        return Colors.orange;
      case LeaveApprovalStatus.approved:
        return Colors.green;
      case LeaveApprovalStatus.rejected:
        return Colors.red;
    }
  }
}

class HrEmployeeRecord {
  final String id;
  String fullName;
  String email;
  String department;
  String position;
  String joinDate;
  bool isActive;
  String? managerId;

  // Data sensitif (M2)
  String nik;
  String npwp;
  String bankAccount;
  String address;
  String emergencyContact;

  // Komponen gaji per karyawan (M5)
  int baseSalary;
  int allowance;
  int deduction;

  HrEmployeeRecord({
    required this.id,
    required this.fullName,
    required this.email,
    required this.department,
    required this.position,
    required this.joinDate,
    this.isActive = true,
    this.managerId,
    required this.nik,
    required this.npwp,
    required this.bankAccount,
    required this.address,
    required this.emergencyContact,
    required this.baseSalary,
    required this.allowance,
    required this.deduction,
  });

  int get netSalary => baseSalary + allowance - deduction;
}

class HrAttendanceEntry {
  final String employeeId;
  final String employeeName;
  final String department;
  final String date;
  final String checkIn;
  final String checkOut;
  final String status;

  HrAttendanceEntry({
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
  });
}

class HrLeaveItem {
  final String id;
  final String employeeId;
  final String employeeName;
  final String department;
  final String type;
  final String dateRange;
  final int days;
  final String reason;
  final String? approverName;
  LeaveApprovalStatus status;

  HrLeaveItem({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.type,
    required this.dateRange,
    required this.days,
    required this.reason,
    this.approverName,
    required this.status,
  });

  bool get hasNoApprover => approverName == null || approverName!.isEmpty;
}

class HrDashboardPage extends StatefulWidget {
  const HrDashboardPage({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<HrDashboardPage> createState() => _HrDashboardPageState();
}

class _HrDashboardPageState extends State<HrDashboardPage> {
  // --- State M2: Kelola Karyawan & Tetapkan Atasan ---
  final TextEditingController _employeeSearchCtrl = TextEditingController();
  String? _selectedDepartmentFilter;

  final List<HrEmployeeRecord> _employees = [
    HrEmployeeRecord(
      id: 'emp-001',
      fullName: 'Dimas Pratama',
      email: 'dimas.lead@perusahaan.co.id',
      department: 'Engineering',
      position: 'Engineering Lead',
      joinDate: '10 Jan 2024',
      isActive: true,
      managerId: null,
      nik: '3404011001950001',
      npwp: '09.123.456.7-542.000',
      bankAccount: 'BCA 1234567890 a.n. Dimas Pratama',
      address: 'Jl. Kaliurang Km 7, Sleman, Yogyakarta',
      emergencyContact: 'Rina (Istri) - 081211112222',
      baseSalary: 14000000,
      allowance: 2500000,
      deduction: 700000,
    ),
    HrEmployeeRecord(
      id: 'emp-002',
      fullName: 'Rizky Ramadhan',
      email: 'rizky.dev@perusahaan.co.id',
      department: 'Engineering',
      position: 'Software Developer',
      joinDate: '12 Jan 2025',
      isActive: true,
      managerId: 'emp-001',
      nik: '3309051203040002',
      npwp: '09.234.567.8-542.000',
      bankAccount: 'Mandiri 1370009876543 a.n. Rizky Ramadhan',
      address: 'Trihanggo, Gamping, Sleman, Yogyakarta',
      emergencyContact: 'Suyanto (Ayah) - 081322223333',
      baseSalary: 8500000,
      allowance: 1250000,
      deduction: 425000,
    ),
    HrEmployeeRecord(
      id: 'emp-003',
      fullName: 'Sari Wulandari',
      email: 'sari.ops@perusahaan.co.id',
      department: 'Operations',
      position: 'Operations Specialist',
      joinDate: '03 Mar 2025',
      isActive: true,
      managerId: null,
      nik: '3471024303990003',
      npwp: '09.345.678.9-541.000',
      bankAccount: 'BNI 0987654321 a.n. Sari Wulandari',
      address: 'Jl. Magelang Km 5, Sleman, Yogyakarta',
      emergencyContact: 'Wulan (Ibu) - 081533334444',
      baseSalary: 7000000,
      allowance: 1000000,
      deduction: 350000,
    ),
  ];

  // --- State M3: Absensi Semua Karyawan ---
  String _attendanceDeptFilter = 'Semua';
  final List<HrAttendanceEntry> _allAttendance = [
    HrAttendanceEntry(
      employeeId: 'emp-001',
      employeeName: 'Dimas Pratama',
      department: 'Engineering',
      date: '26 Nov 2026',
      checkIn: '08:15',
      checkOut: '17:40',
      status: 'Tepat Waktu',
    ),
    HrAttendanceEntry(
      employeeId: 'emp-002',
      employeeName: 'Rizky Ramadhan',
      department: 'Engineering',
      date: '26 Nov 2026',
      checkIn: '08:41',
      checkOut: '17:35',
      status: 'Terlambat',
    ),
    HrAttendanceEntry(
      employeeId: 'emp-003',
      employeeName: 'Sari Wulandari',
      department: 'Operations',
      date: '26 Nov 2026',
      checkIn: '08:22',
      checkOut: '17:30',
      status: 'Tepat Waktu',
    ),
    HrAttendanceEntry(
      employeeId: 'emp-002',
      employeeName: 'Rizky Ramadhan',
      department: 'Engineering',
      date: '25 Nov 2026',
      checkIn: '08:25',
      checkOut: '17:35',
      status: 'Tepat Waktu',
    ),
  ];

  // --- State M4: Kelola Cuti ---
  bool _onlyNoApproverFilter = false;
  final List<HrLeaveItem> _allLeaves = [
    HrLeaveItem(
      id: 'LV-101',
      employeeId: 'emp-003',
      employeeName: 'Sari Wulandari',
      department: 'Operations',
      type: 'Cuti Tahunan',
      dateRange: '01 Des 2026 - 02 Des 2026',
      days: 2,
      reason: 'Keperluan keluarga',
      approverName: null,
      status: LeaveApprovalStatus.pending,
    ),
    HrLeaveItem(
      id: 'LV-102',
      employeeId: 'emp-002',
      employeeName: 'Rizky Ramadhan',
      department: 'Engineering',
      type: 'Cuti Tahunan',
      dateRange: '10 Des 2026 - 12 Des 2026',
      days: 3,
      reason: 'Acara keluarga di luar kota',
      approverName: 'Dimas Pratama (Lead)',
      status: LeaveApprovalStatus.pending,
    ),
    HrLeaveItem(
      id: 'LV-103',
      employeeId: 'emp-001',
      employeeName: 'Dimas Pratama',
      department: 'Engineering',
      type: 'Cuti Sakit',
      dateRange: '18 Nov 2026',
      days: 1,
      reason: 'Pemeriksaan kesehatan rutin',
      approverName: null,
      status: LeaveApprovalStatus.approved,
    ),
  ];

  // --- State M5: Payroll ---
  String _selectedPayrollPeriod = 'November 2026';

  @override
  void dispose() {
    _employeeSearchCtrl.dispose();
    super.dispose();
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

  bool _isLead(HrEmployeeRecord emp) {
    return _employees.any((other) => other.managerId == emp.id);
  }

  String _getManagerName(String? managerId) {
    if (managerId == null) return 'Belum ditetapkan (Top-level)';
    final found = _employees.where((e) => e.id == managerId);
    return found.isNotEmpty ? found.first.fullName : 'Tidak ditemukan';
  }

  // --- Dialog Tambah / Ubah Karyawan (M2) ---
  Future<void> _showEmployeeFormDialog({HrEmployeeRecord? existing}) async {
    final formKey = GlobalKey<FormState>();
    final isEdit = existing != null;

    final nameCtrl = TextEditingController(text: existing?.fullName ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final deptCtrl = TextEditingController(
      text: existing?.department ?? 'Engineering',
    );
    final posCtrl = TextEditingController(text: existing?.position ?? '');
    final joinCtrl = TextEditingController(
      text: existing?.joinDate ?? '26 Nov 2026',
    );
    bool isActive = existing?.isActive ?? true;

    // Data sensitif
    final nikCtrl = TextEditingController(text: existing?.nik ?? '');
    final npwpCtrl = TextEditingController(text: existing?.npwp ?? '');
    final bankCtrl = TextEditingController(text: existing?.bankAccount ?? '');
    final addrCtrl = TextEditingController(text: existing?.address ?? '');
    final emergencyCtrl = TextEditingController(
      text: existing?.emergencyContact ?? '',
    );

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Ubah Data Karyawan' : 'Tambah Karyawan Baru'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Dasar Karyawan',
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email Perusahaan',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Email tidak valid'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: deptCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Departemen',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Wajib diisi'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: posCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Jabatan',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Wajib diisi'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: joinCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Tanggal Masuk',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Status Aktif',
                              style: TextStyle(fontSize: 13),
                            ),
                            value: isActive,
                            onChanged: (val) =>
                                setDialogState(() => isActive = val),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      'Data Sensitif & Administrasi (M2)',
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: nikCtrl,
                            decoration: const InputDecoration(
                              labelText: 'NIK (16 digit)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'NIK wajib diisi'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: npwpCtrl,
                            decoration: const InputDecoration(
                              labelText: 'NPWP',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: bankCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Rekening & Bank',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Rekening wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: addrCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Alamat Domisili',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emergencyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Kontak Darurat (Nama, Hubungan, No. HP)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Kontak darurat wajib diisi'
                          : null,
                    ),
                  ],
                ),
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
                // TODO: Simpan/update data karyawan ke backend (M2)
                setState(() {
                  if (isEdit) {
                    existing.fullName = nameCtrl.text.trim();
                    existing.email = emailCtrl.text.trim();
                    existing.department = deptCtrl.text.trim();
                    existing.position = posCtrl.text.trim();
                    existing.joinDate = joinCtrl.text.trim();
                    existing.isActive = isActive;
                    existing.nik = nikCtrl.text.trim();
                    existing.npwp = npwpCtrl.text.trim();
                    existing.bankAccount = bankCtrl.text.trim();
                    existing.address = addrCtrl.text.trim();
                    existing.emergencyContact = emergencyCtrl.text.trim();
                  } else {
                    _employees.insert(
                      0,
                      HrEmployeeRecord(
                        id: 'emp-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
                        fullName: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        department: deptCtrl.text.trim(),
                        position: posCtrl.text.trim(),
                        joinDate: joinCtrl.text.trim(),
                        isActive: isActive,
                        nik: nikCtrl.text.trim(),
                        npwp: npwpCtrl.text.trim(),
                        bankAccount: bankCtrl.text.trim(),
                        address: addrCtrl.text.trim(),
                        emergencyContact: emergencyCtrl.text.trim(),
                        baseSalary: 6000000,
                        allowance: 500000,
                        deduction: 300000,
                      ),
                    );
                  }
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEdit
                          ? 'Data karyawan diperbarui.'
                          : 'Karyawan baru berhasil ditambahkan.',
                    ),
                  ),
                );
              },
              child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Karyawan'),
            ),
          ],
        ),
      ),
    );
  }

  // --- Dialog Tetapkan Atasan / manager_id (M2) ---
  Future<void> _showAssignManagerDialog(HrEmployeeRecord employee) async {
    String? selectedManagerId = employee.managerId;
    final candidates = _employees
        .where((e) => e.id != employee.id && e.isActive)
        .toList();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Tetapkan Atasan (manager_id)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Karyawan: ${employee.fullName} (${employee.department})',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              const Text(
                'Karyawan yang ditetapkan sebagai atasan otomatis berstatus Lead dan menjadi approver cuti bagi anggota timnya.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: selectedManagerId,
                decoration: const InputDecoration(
                  labelText: 'Pilih Atasan Langsung',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Tidak ada atasan (Top-level)'),
                  ),
                  ...candidates.map(
                    (c) => DropdownMenuItem<String?>(
                      value: c.id,
                      child: Text('${c.fullName} • ${c.position}'),
                    ),
                  ),
                ],
                onChanged: (val) =>
                    setDialogState(() => selectedManagerId = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                // TODO: Update manager_id pada database (M2)
                setState(() => employee.managerId = selectedManagerId);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Atasan untuk ${employee.fullName} berhasil diperbarui.',
                    ),
                  ),
                );
              },
              child: const Text('Simpan Atasan'),
            ),
          ],
        ),
      ),
    );
  }

  // --- Dialog Detail Sensitif Karyawan (M2) ---
  void _showEmployeeSensitiveDetail(HrEmployeeRecord emp) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(emp.fullName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Email', emp.email),
              _detailRow(
                'Departemen / Jabatan',
                '${emp.department} • ${emp.position}',
              ),
              _detailRow('Tanggal Masuk', emp.joinDate),
              _detailRow('Atasan (manager_id)', _getManagerName(emp.managerId)),
              const Divider(),
              _detailRow('NIK', emp.nik),
              _detailRow('NPWP', emp.npwp),
              _detailRow('Rekening Bank', emp.bankAccount),
              _detailRow('Alamat', emp.address),
              _detailRow('Kontak Darurat', emp.emergencyContact),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // --- Dialog Komponen Gaji & Slip Gaji (M5) ---
  Future<void> _showSalaryComponentDialog(HrEmployeeRecord emp) async {
    final formKey = GlobalKey<FormState>();
    final baseCtrl = TextEditingController(text: emp.baseSalary.toString());
    final allowCtrl = TextEditingController(text: emp.allowance.toString());
    final deductCtrl = TextEditingController(text: emp.deduction.toString());

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Komponen Gaji • ${emp.fullName}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: baseCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Gaji Pokok (Rp)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (int.tryParse(v ?? '') == null)
                    ? 'Masukkan angka valid'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: allowCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tunjangan Tetap (Rp)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (int.tryParse(v ?? '') == null)
                    ? 'Masukkan angka valid'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: deductCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Potongan (BPJS/Pajak) (Rp)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (int.tryParse(v ?? '') == null)
                    ? 'Masukkan angka valid'
                    : null,
              ),
            ],
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
              // TODO: Simpan komponen gaji karyawan ke backend (M5)
              setState(() {
                emp.baseSalary = int.parse(baseCtrl.text);
                emp.allowance = int.parse(allowCtrl.text);
                emp.deduction = int.parse(deductCtrl.text);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Komponen gaji ${emp.fullName} berhasil disimpan.',
                  ),
                ),
              );
            },
            child: const Text('Simpan Komponen'),
          ),
        ],
      ),
    );
  }

  void _showPayslipPreviewDialog(HrEmployeeRecord emp) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Slip Gaji • $_selectedPayrollPeriod'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${emp.fullName} (${emp.position})'),
            Text(
              'Rekening: ${emp.bankAccount}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 20),
            _salaryLine('Gaji Pokok', _formatRupiah(emp.baseSalary)),
            const SizedBox(height: 6),
            _salaryLine('Tunjangan', _formatRupiah(emp.allowance)),
            const SizedBox(height: 6),
            _salaryLine(
              'Potongan',
              '- ${_formatRupiah(emp.deduction)}',
              color: Colors.red.shade700,
            ),
            const Divider(height: 20),
            _salaryLine(
              'Take Home Pay',
              _formatRupiah(emp.netSalary),
              isBold: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _salaryLine(
    String label,
    String val, {
    bool isBold = false,
    Color? color,
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
          val,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      title: 'HR',
      onLogout: widget.onLogout,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.badge_outlined),
          selectedIcon: Icon(Icons.badge),
          label: 'Karyawan',
        ),
        NavigationDestination(
          icon: Icon(Icons.fact_check_outlined),
          selectedIcon: Icon(Icons.fact_check),
          label: 'Absensi',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_available_outlined),
          selectedIcon: Icon(Icons.event_available),
          label: 'Cuti',
        ),
        NavigationDestination(
          icon: Icon(Icons.payments_outlined),
          selectedIcon: Icon(Icons.payments),
          label: 'Payroll',
        ),
      ],
      pages: [
        _buildEmployeesTab(),
        _buildAttendanceTab(),
        _buildLeavesTab(),
        _buildPayrollTab(),
      ],
    );
  }

  Widget _buildScopeBanner() {
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
          Icon(
            Icons.admin_panel_settings_outlined,
            size: 18,
            color: Colors.indigo.shade900,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ruang Lingkup HR: Pengelolaan profil & data sensitif karyawan, hierarki atasan (Lead), monitoring absensi, manajemen cuti, dan komponen gaji. Pengaturan akun sistem dikelola Super Admin.',
              style: TextStyle(fontSize: 12, color: Colors.indigo.shade900),
            ),
          ),
        ],
      ),
    );
  }

  /// TAB 1: Kelola Karyawan & Tetapkan Atasan (M2)
  Widget _buildEmployeesTab() {
    final query = _employeeSearchCtrl.text.toLowerCase().trim();
    final departments = _employees.map((e) => e.department).toSet().toList();

    final filtered = _employees.where((emp) {
      final matchSearch =
          query.isEmpty ||
          emp.fullName.toLowerCase().contains(query) ||
          emp.email.toLowerCase().contains(query) ||
          emp.position.toLowerCase().contains(query);
      final matchDept =
          _selectedDepartmentFilter == null ||
          emp.department == _selectedDepartmentFilter;
      return matchSearch && matchDept;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScopeBanner(),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Direktori Karyawan (${_employees.length})',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Kelola data dasar, data sensitif (NIK/NPWP/Rekening), dan penetapan atasan (Lead)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _showEmployeeFormDialog(),
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Tambah Karyawan'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _employeeSearchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari nama, email, atau jabatan...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: _selectedDepartmentFilter,
                  isDense: true,
                  decoration: InputDecoration(
                    labelText: 'Departemen',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Semua'),
                    ),
                    ...departments.map(
                      (d) =>
                          DropdownMenuItem<String?>(value: d, child: Text(d)),
                    ),
                  ],
                  onChanged: (val) =>
                      setState(() => _selectedDepartmentFilter = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final emp = filtered[index];
                final isLead = _isLead(emp);

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
                          children: [
                            CircleAvatar(
                              backgroundColor: emp.isActive
                                  ? Colors.indigo.shade100
                                  : Colors.grey.shade200,
                              child: Text(
                                emp.fullName[0].toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: emp.isActive
                                      ? Colors.indigo.shade900
                                      : Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          emp.fullName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: emp.isActive
                                                ? null
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                      if (isLead) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.indigo.shade50,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.indigo.shade200,
                                            ),
                                          ),
                                          child: Text(
                                            'Lead',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.indigo.shade900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    '${emp.position} • ${emp.department}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                  Text(
                                    'Atasan: ${_getManagerName(emp.managerId)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: emp.isActive,
                              onChanged: (val) {
                                setState(() => emp.isActive = val);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      val
                                          ? 'Karyawan ${emp.fullName} diaktifkan.'
                                          : 'Karyawan ${emp.fullName} dinonaktifkan.',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const Divider(height: 18),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _showEmployeeSensitiveDetail(emp),
                              icon: const Icon(
                                Icons.visibility_outlined,
                                size: 16,
                              ),
                              label: const Text('Detail Sensitif'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _showEmployeeFormDialog(existing: emp),
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Ubah Data'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _showAssignManagerDialog(emp),
                              icon: const Icon(
                                Icons.account_tree_outlined,
                                size: 16,
                              ),
                              label: const Text('Tetapkan Atasan'),
                            ),
                          ],
                        ),
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

  /// TAB 2: Lihat Absensi Semua Karyawan (M3) - Riwayat & Rekap
  Widget _buildAttendanceTab() {
    final departments = [
      'Semua',
      ..._employees.map((e) => e.department).toSet(),
    ];
    final filteredLogs = _attendanceDeptFilter == 'Semua'
        ? _allAttendance
        : _allAttendance
              .where((a) => a.department == _attendanceDeptFilter)
              .toList();

    final onTimeCount = filteredLogs
        .where((a) => a.status == 'Tepat Waktu')
        .length;
    final lateCount = filteredLogs.where((a) => a.status == 'Terlambat').length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Rekap & Riwayat Absensi Karyawan',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 160,
              child: DropdownButtonFormField<String>(
                value: _attendanceDeptFilter,
                isDense: true,
                decoration: const InputDecoration(
                  labelText: 'Departemen',
                  border: OutlineInputBorder(),
                ),
                items: departments
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _attendanceDeptFilter = val);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statBox(
                'Total Log',
                '${filteredLogs.length}',
                Colors.indigo,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statBox('Tepat Waktu', '$onTimeCount', Colors.green),
            ),
            const SizedBox(width: 10),
            Expanded(child: _statBox('Terlambat', '$lateCount', Colors.orange)),
          ],
        ),
        const SizedBox(height: 16),
        ...filteredLogs.map(
          (log) => Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: ListTile(
              title: Text(
                '${log.employeeName} • ${log.department}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${log.date}  |  Masuk: ${log.checkIn} • Pulang: ${log.checkOut}',
              ),
              trailing: Chip(
                label: Text(log.status, style: const TextStyle(fontSize: 12)),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  /// TAB 3: Kelola Cuti (M4) - Pantau semua & ambil alih yang tanpa approver
  Widget _buildLeavesTab() {
    final visibleLeaves = _onlyNoApproverFilter
        ? _allLeaves.where((l) => l.hasNoApprover).toList()
        : _allLeaves;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monitoring & Eskalasi Cuti (M4)',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'HR dapat mengambil alih pengajuan yang tidak memiliki approver (atasan)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              FilterChip(
                label: const Text('Tanpa Approver'),
                selected: _onlyNoApproverFilter,
                onSelected: (val) =>
                    setState(() => _onlyNoApproverFilter = val),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: visibleLeaves.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final leave = visibleLeaves[index];
                final canHrTakeOver =
                    leave.hasNoApprover &&
                    leave.status == LeaveApprovalStatus.pending;

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: canHrTakeOver
                          ? Colors.orange.shade300
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${leave.employeeName} (${leave.department})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: leave.status.color.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                leave.status.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: leave.status.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${leave.type} • ${leave.dateRange} (${leave.days} hari)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text('Alasan: ${leave.reason}'),
                        const SizedBox(height: 6),
                        Text(
                          leave.hasNoApprover
                              ? 'Approver: Tidak ada atasan (Membutuhkan tindakan HR)'
                              : 'Approver: ${leave.approverName}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: leave.hasNoApprover
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: leave.hasNoApprover
                                ? Colors.orange.shade900
                                : Colors.grey.shade700,
                          ),
                        ),
                        if (canHrTakeOver) ...[
                          const Divider(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(
                                    () => leave.status =
                                        LeaveApprovalStatus.rejected,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Cuti ${leave.employeeName} ditolak oleh HR.',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.close, size: 16),
                                label: const Text('Tolak (HR)'),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.icon(
                                onPressed: () {
                                  setState(
                                    () => leave.status =
                                        LeaveApprovalStatus.approved,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Cuti ${leave.employeeName} disetujui HR (ambil alih).',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.check, size: 16),
                                label: const Text('Ambil Alih & Setujui'),
                              ),
                            ],
                          ),
                        ],
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

  /// TAB 4: Kelola Payroll (M5) - Komponen gaji & lihat slip gaji karyawan
  Widget _buildPayrollTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Komponen Gaji & Slip Karyawan (M5)',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Atur gaji pokok, tunjangan, potongan, serta tinjau slip gaji per karyawan',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 175,
                child: DropdownButtonFormField<String>(
                  value: _selectedPayrollPeriod,
                  isDense: true,
                  decoration: const InputDecoration(
                    labelText: 'Periode Slip',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'November 2026',
                      child: Text('November 2026'),
                    ),
                    DropdownMenuItem(
                      value: 'Oktober 2026',
                      child: Text('Oktober 2026'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedPayrollPeriod = val);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _employees.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final emp = _employees[index];
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    emp.fullName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${emp.position} • ${emp.department}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _formatRupiah(emp.netSalary),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pokok: ${_formatRupiah(emp.baseSalary)}  •  Tunjangan: ${_formatRupiah(emp.allowance)}  •  Potongan: ${_formatRupiah(emp.deduction)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Divider(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _showPayslipPreviewDialog(emp),
                              icon: const Icon(
                                Icons.receipt_long_outlined,
                                size: 16,
                              ),
                              label: const Text('Lihat Slip Gaji'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed: () => _showSalaryComponentDialog(emp),
                              icon: const Icon(Icons.tune, size: 16),
                              label: const Text('Atur Komponen'),
                            ),
                          ],
                        ),
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
}
