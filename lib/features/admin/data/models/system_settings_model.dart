import 'package:hris_apps/features/admin/domain/entities/system_settings.dart';

class SystemSettingsModel extends SystemSettings {
  const SystemSettingsModel({
    required super.companyName,
    required super.clockInHour,
    required super.clockInMinute,
    required super.clockOutHour,
    required super.clockOutMinute,
  });

  factory SystemSettingsModel.fromEntity(SystemSettings entity) {
    return SystemSettingsModel(
      companyName: entity.companyName,
      clockInHour: entity.clockInHour,
      clockInMinute: entity.clockInMinute,
      clockOutHour: entity.clockOutHour,
      clockOutMinute: entity.clockOutMinute,
    );
  }

  factory SystemSettingsModel.fromJson(Map<String, dynamic> json) {
    return SystemSettingsModel(
      companyName: json['company_name'] as String,
      clockInHour: json['clock_in_hour'] as int,
      clockInMinute: json['clock_in_minute'] as int,
      clockOutHour: json['clock_out_hour'] as int,
      clockOutMinute: json['clock_out_minute'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'clock_in_hour': clockInHour,
      'clock_in_minute': clockInMinute,
      'clock_out_hour': clockOutHour,
      'clock_out_minute': clockOutMinute,
    };
  }
}
