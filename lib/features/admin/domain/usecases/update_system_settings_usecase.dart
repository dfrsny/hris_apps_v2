import 'package:hris_apps/features/admin/domain/entities/system_settings.dart';
import 'package:hris_apps/features/admin/domain/repositories/admin_repository.dart';

class UpdateSystemSettingsUseCase {
  final AdminRepository repository;
  UpdateSystemSettingsUseCase(this.repository);

  Future<SystemSettings> call(SystemSettings settings) {
    return repository.updateSystemSettings(settings);
  }
}
