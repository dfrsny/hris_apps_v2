import 'package:material_ui/material_ui.dart';
import 'package:hris_apps/features/finance/domain/entities/monthly_payroll_batch.dart';

extension PayrollStatusUiExt on PayrollStatus {
  String get label {
    switch (this) {
      case PayrollStatus.draft:
        return 'Belum Diproses';
      case PayrollStatus.processed:
        return 'Selesai Diproses';
      case PayrollStatus.finalized:
        return 'Terkunci (Final)';
    }
  }

  Color get color {
    switch (this) {
      case PayrollStatus.draft:
        return Colors.orange;
      case PayrollStatus.processed:
        return Colors.blue;
      case PayrollStatus.finalized:
        return Colors.green;
    }
  }
}
