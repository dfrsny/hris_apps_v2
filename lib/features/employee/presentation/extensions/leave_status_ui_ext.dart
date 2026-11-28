import 'package:material_ui/material_ui.dart';
import 'package:hris_apps/features/employee/domain/entities/leave_request.dart';

extension LeaveStatusUiExt on LeaveStatus {
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
