class AttendanceRecord {
  final DateTime rawDate;
  final String date;
  final String checkIn;
  final String checkOut;
  final String status;

  const AttendanceRecord({
    required this.rawDate,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
  });

  AttendanceRecord copyWith({
    DateTime? rawDate,
    String? date,
    String? checkIn,
    String? checkOut,
    String? status,
  }) {
    return AttendanceRecord(
      rawDate: rawDate ?? this.rawDate,
      date: date ?? this.date,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
    );
  }
}
