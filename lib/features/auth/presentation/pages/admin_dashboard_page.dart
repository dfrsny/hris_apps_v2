import 'package:material_ui/material_ui.dart';
import 'package:hris_apps/features/auth/domain/entities/user_role.dart';
import 'package:hris_apps/features/auth/presentation/widgets/dashboard_scaffold.dart';

// Role yang boleh dikelola lewat UI (Super Admin hanya bisa diberikan lewat SQL manual)
const List<UserRole> _manageableRoles = [
  UserRole.hr,
  UserRole.finance,
  UserRole.employee,
];

extension ManageableUserRoleExt on UserRole {
  String get label {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.hr:
        return 'HR';
      case UserRole.finance:
        return 'Finance';
      case UserRole.employee:
        return 'Employee';
    }
  }

  Color get color {
    switch (this) {
      case UserRole.superAdmin:
        return Colors.deepPurple;
      case UserRole.hr:
        return Colors.indigo;
      case UserRole.finance:
        return Colors.teal;
      case UserRole.employee:
        return Colors.blueGrey;
    }
  }
}

class ManagedAccount {
  final String id;
  final String email;
  final String displayName;
  UserRole role;
  bool isActive;

  ManagedAccount({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.isActive = true,
  });
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- State Kelola Akun (M1 sebagian, M2 lengkap) ---
  final TextEditingController _searchController = TextEditingController();
  UserRole? _filterRole;
  bool _isCreatingAccount = false;

  final List<ManagedAccount> _accounts = [
    ManagedAccount(
      id: 'usr-001',
      email: 'nadia.hr@perusahaan.co.id',
      displayName: 'Nadia Pratama',
      role: UserRole.hr,
      isActive: true,
    ),
    ManagedAccount(
      id: 'usr-002',
      email: 'budi.fin@perusahaan.co.id',
      displayName: 'Budi Santoso',
      role: UserRole.finance,
      isActive: true,
    ),
    ManagedAccount(
      id: 'usr-003',
      email: 'rizky.dev@perusahaan.co.id',
      displayName: 'Rizky Ramadhan',
      role: UserRole.employee,
      isActive: true,
    ),
    ManagedAccount(
      id: 'usr-004',
      email: 'sari.ops@perusahaan.co.id',
      displayName: 'Sari Wulandari',
      role: UserRole.employee,
      isActive: false,
    ),
  ];

  // --- State Pengaturan Sistem (M6) ---
  final _systemFormKey = GlobalKey<FormState>();
  final TextEditingController _companyNameController = TextEditingController(
    text: 'PT Nusantara Teknologi Digital',
  );
  TimeOfDay _clockInTime = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay _clockOutTime = const TimeOfDay(hour: 17, minute: 30);
  bool _isSavingSettings = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  List<ManagedAccount> get _filteredAccounts {
    final query = _searchController.text.toLowerCase().trim();
    return _accounts.where((acc) {
      final matchesQuery =
          query.isEmpty ||
          acc.email.toLowerCase().contains(query) ||
          acc.displayName.toLowerCase().contains(query);
      final matchesRole = _filterRole == null || acc.role == _filterRole;
      return matchesQuery && matchesRole;
    }).toList();
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _showCreateAccountDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    UserRole selectedRole = UserRole.employee;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Buat Akun Baru'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Akun dibuat lewat Edge Function. Role Super Admin hanya dapat diberikan melalui SQL manual.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nama Tampilan Akun',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? 'Nama wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Login',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || !val.contains('@')) {
                            return 'Masukkan email yang valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passwordCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password Sementara',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => (val == null || val.length < 8)
                            ? 'Minimal 8 karakter'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<UserRole>(
                        initialValue: selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role Akses',
                          border: OutlineInputBorder(),
                        ),
                        items: _manageableRoles.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role.label),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedRole = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isCreatingAccount
                      ? null
                      : () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                FilledButton.icon(
                  onPressed: _isCreatingAccount
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setDialogState(() => _isCreatingAccount = true);

                          // TODO: Panggil Edge Function pembuatan akun (mis. supabase.functions.invoke('create-user', body: ...))
                          await Future<void>.delayed(
                            const Duration(milliseconds: 600),
                          );

                          if (!mounted) return;
                          setState(() {
                            _accounts.insert(
                              0,
                              ManagedAccount(
                                id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
                                email: emailCtrl.text.trim(),
                                displayName: nameCtrl.text.trim(),
                                role: selectedRole,
                              ),
                            );
                            _isCreatingAccount = false;
                          });

                          if (ctx.mounted) Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Akun ${emailCtrl.text.trim()} (${selectedRole.label}) berhasil dibuat.',
                              ),
                            ),
                          );
                        },
                  icon: _isCreatingAccount
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.person_add, size: 18),
                  label: const Text('Buat Akun'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveSystemSettings() async {
    if (!_systemFormKey.currentState!.validate()) return;

    setState(() => _isSavingSettings = true);

    // TODO: Simpan pengaturan M6 (nama perusahaan & jam kerja) ke database
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() => _isSavingSettings = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengaturan sistem berhasil diperbarui.')),
    );
  }

  Future<void> _pickTime({required bool isClockIn}) async {
    final initial = isClockIn ? _clockInTime : _clockOutTime;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        if (isClockIn) {
          _clockInTime = picked;
        } else {
          _clockOutTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      title: 'Super Admin',
      onLogout: widget.onLogout,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.manage_accounts_outlined),
          selectedIcon: Icon(Icons.manage_accounts),
          label: 'Akun',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Sistem',
        ),
      ],
      pages: [_buildAccountManagementTab(), _buildSystemSettingsTab()],
    );
  }

  Widget _buildAccountManagementTab() {
    final accounts = _filteredAccounts;
    final activeCount = _accounts.where((a) => a.isActive).length;

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
                      'Daftar Akun Pengguna (${_accounts.length})',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$activeCount akun aktif • Role Super Admin hanya dapat diberikan via SQL manual',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: _showCreateAccountDialog,
                icon: const Icon(Icons.add),
                label: const Text('Buat Akun'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari nama akun atau email...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<UserRole?>(
                  value: _filterRole,
                  isDense: true,
                  decoration: InputDecoration(
                    labelText: 'Filter Role',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<UserRole?>(
                      value: null,
                      child: Text('Semua Role'),
                    ),
                    ..._manageableRoles.map(
                      (r) => DropdownMenuItem<UserRole?>(
                        value: r,
                        child: Text(r.label),
                      ),
                    ),
                  ],
                  onChanged: (val) => setState(() => _filterRole = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: accounts.isEmpty
                ? const Center(
                    child: Text('Tidak ada akun yang sesuai filter.'),
                  )
                : ListView.separated(
                    itemCount: accounts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: account.isActive
                                    ? account.role.color.withValues(alpha: 0.15)
                                    : Colors.grey.shade200,
                                child: Text(
                                  account.displayName.isNotEmpty
                                      ? account.displayName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: account.isActive
                                        ? account.role.color
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      account.displayName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: account.isActive
                                            ? null
                                            : Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      account.email,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 130,
                                child: DropdownButtonFormField<UserRole>(
                                  value: account.role,
                                  isDense: true,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _manageableRoles.map((role) {
                                    return DropdownMenuItem(
                                      value: role,
                                      child: Text(
                                        role.label,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newRole) {
                                    if (newRole != null &&
                                        newRole != account.role) {
                                      setState(() => account.role = newRole);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Role ${account.displayName} diubah ke ${newRole.label}.',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                children: [
                                  Switch(
                                    value: account.isActive,
                                    onChanged: (val) {
                                      setState(() => account.isActive = val);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            val
                                                ? 'Akun ${account.email} diaktifkan.'
                                                : 'Akun ${account.email} dinonaktifkan.',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  Text(
                                    account.isActive ? 'Aktif' : 'Nonaktif',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: account.isActive
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                    ),
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

  Widget _buildSystemSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _systemFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Konfigurasi Perusahaan & Jam Kerja',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pengaturan dasar sistem yang berlaku secara global.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Divider(height: 28),
                    TextFormField(
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Perusahaan',
                        prefixIcon: Icon(Icons.business_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'Nama perusahaan tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Standar Jam Kerja Operasional',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickTime(isClockIn: true),
                            borderRadius: BorderRadius.circular(8),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Jam Masuk',
                                prefixIcon: Icon(Icons.login_outlined),
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _formatTime(_clockInTime),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickTime(isClockIn: false),
                            borderRadius: BorderRadius.circular(8),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Jam Pulang',
                                prefixIcon: Icon(Icons.logout_outlined),
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _formatTime(_clockOutTime),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _isSavingSettings
                            ? null
                            : _saveSystemSettings,
                        icon: _isSavingSettings
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: const Text('Simpan Pengaturan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
