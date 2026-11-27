class SystemSettings {
  final String companyName;
  final int clockInHour;
  final int clockInMinute;
  final int clockOutHour;
  final int clockOutMinute;

  const SystemSettings({
    required this.companyName,
    required this.clockInHour,
    required this.clockInMinute,
    required this.clockOutHour,
    required this.clockOutMinute,
  });

  SystemSettings copyWith({
    String? companyName,
    int? clockInHour,
    int? clockInMinute,
    int? clockOutHour,
    int? clockOutMinute,
  }) {
    return SystemSettings(
      companyName: companyName ?? this.companyName,
      clockInHour: clockInHour ?? this.clockInHour,
      clockInMinute: clockInMinute ?? this.clockInMinute,
      clockOutHour: clockOutHour ?? this.clockOutHour,
      clockOutMinute: clockOutMinute ?? this.clockOutMinute,
    );
  }
}
