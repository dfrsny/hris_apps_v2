import 'package:hris_apps/features/admin/domain/entities/system_settings.dart';
import 'package:hris_apps/features/admin/domain/repositories/admin_repository.dart';

class GetSystemSettingsUseCase {
  final AdminRepository repository;
  GetSystemSettingsUseCase(this.repository);

  Future<SystemSettings> call() => repository.getSystemSettings();
}
