import 'package:material_ui/material_ui.dart';
import 'package:hris_apps/features/admin/domain/entities/managed_account.dart';
import 'package:hris_apps/features/admin/domain/entities/system_settings.dart';
import 'package:hris_apps/features/admin/domain/usecases/create_account_usecase.dart';
import 'package:hris_apps/features/admin/domain/usecases/get_accounts_usecase.dart';
import 'package:hris_apps/features/admin/domain/usecases/get_system_settings_usecase.dart';
import 'package:hris_apps/features/admin/domain/usecases/update_account_role_usecase.dart';
import 'package:hris_apps/features/admin/domain/usecases/update_account_status_usecase.dart';
import 'package:hris_apps/features/admin/domain/usecases/update_system_settings_usecase.dart';
import 'package:hris_apps/features/auth/domain/entities/user_role.dart';

class AdminProvider extends ChangeNotifier {
  final GetAccountsUseCase getAccountsUseCase;
  final CreateAccountUseCase createAccountUseCase;
  final UpdateAccountRoleUseCase updateAccountRoleUseCase;
  final UpdateAccountStatusUseCase updateAccountStatusUseCase;
  final GetSystemSettingsUseCase getSystemSettingsUseCase;
  final UpdateSystemSettingsUseCase updateSystemSettingsUseCase;

  AdminProvider({
    required this.getAccountsUseCase,
    required this.createAccountUseCase,
    required this.updateAccountRoleUseCase,
    required this.updateAccountStatusUseCase,
    required this.getSystemSettingsUseCase,
    required this.updateSystemSettingsUseCase,
  });

  // --- Accounts State ---
  List<ManagedAccount> _accounts = [];
  String _searchQuery = '';
  UserRole? _filterRole;
  bool _isLoadingAccounts = false;
  bool _isCreatingAccount = false;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- System Settings State ---
  SystemSettings? _systemSettings;
  bool _isLoadingSettings = false;
  bool _isSavingSettings = false;

  // --- Getters ---
  bool get isLoadingAccounts => _isLoadingAccounts;
  bool get isCreatingAccount => _isCreatingAccount;
  bool get isLoadingSettings => _isLoadingSettings;
  bool get isSavingSettings => _isSavingSettings;
  UserRole? get filterRole => _filterRole;
  String get searchQuery => _searchQuery;
  int get totalAccountsCount => _accounts.length;
  int get activeAccountsCount => _accounts.where((a) => a.isActive).length;
  SystemSettings? get systemSettings => _systemSettings;

  List<ManagedAccount> get filteredAccounts {
    final query = _searchQuery.toLowerCase().trim();
    return _accounts.where((acc) {
      final matchesQuery =
          query.isEmpty ||
          acc.email.toLowerCase().contains(query) ||
          acc.displayName.toLowerCase().contains(query);
      final matchesRole = _filterRole == null || acc.role == _filterRole;
      return matchesQuery && matchesRole;
    }).toList();
  }

  // --- Initialization ---
  Future<void> initializeDashboard() async {
    await Future.wait([loadAccounts(), loadSystemSettings()]);
  }

  Future<void> loadAccounts() async {
    _isLoadingAccounts = true;
    notifyListeners();
    try {
      final result = await getAccountsUseCase();

      _accounts = List<ManagedAccount>.from(result);
    } finally {
      _isLoadingAccounts = false;
      notifyListeners();
    }
  }

  Future<void> loadSystemSettings() async {
    _isLoadingSettings = true;
    notifyListeners();
    try {
      _systemSettings = await getSystemSettingsUseCase();
    } finally {
      _isLoadingSettings = false;
      notifyListeners();
    }
  }

  // --- Filter & Search ---
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterRole(UserRole? role) {
    _filterRole = role;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterRole = null;
    notifyListeners();
  }

  Future<bool> createAccount({
    required String displayName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _isCreatingAccount = true;
    notifyListeners();
    try {
      final created = await createAccountUseCase(
        displayName: displayName,
        email: email,
        password: password,
        role: role,
      );
      _accounts = List<ManagedAccount>.from([created, ..._accounts]);
      return true;
    } catch (_) {
      return false;
    } finally {
      _isCreatingAccount = false;
      notifyListeners();
    }
  }

  Future<bool> changeAccountRole(String accountId, UserRole newRole) async {
    final index = _accounts.indexWhere((a) => a.id == accountId);
    if (index == -1 || _accounts[index].role == newRole) return false;

    final previous = _accounts[index];
    // Optimistic update
    _accounts[index] = previous.copyWith(role: newRole);
    notifyListeners();

    try {
      final updated = await updateAccountRoleUseCase(accountId, newRole);
      _accounts[index] = updated;
      notifyListeners();
      return true;
    } catch (_) {
      // Rollback jika gagal
      _accounts[index] = previous;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleAccountStatus(String accountId, bool isActive) async {
    final index = _accounts.indexWhere((a) => a.id == accountId);
    if (index == -1) return false;

    final previous = _accounts[index];
    _errorMessage = null;
    // Optimistic update
    _accounts[index] = previous.copyWith(isActive: isActive);
    notifyListeners();

    try {
      final updated = await updateAccountStatusUseCase(accountId, isActive);
      _accounts[index] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      // Rollback jika gagal & simpan pesan error
      _accounts[index] = previous;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('=== TOGGLE STATUS ERROR === $_errorMessage');
      notifyListeners();
      return false;
    }
  }

  // --- Settings Mutations ---
  Future<bool> saveSystemSettings({
    required String companyName,
    required TimeOfDay clockIn,
    required TimeOfDay clockOut,
  }) async {
    _isSavingSettings = true;
    notifyListeners();
    try {
      final updated = await updateSystemSettingsUseCase(
        SystemSettings(
          companyName: companyName.trim(),
          clockInHour: clockIn.hour,
          clockInMinute: clockIn.minute,
          clockOutHour: clockOut.hour,
          clockOutMinute: clockOut.minute,
        ),
      );
      _systemSettings = updated;
      return true;
    } catch (_) {
      return false;
    } finally {
      _isSavingSettings = false;
      notifyListeners();
    }
  }
}
