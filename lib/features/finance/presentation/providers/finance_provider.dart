import 'package:material_ui/material_ui.dart';
import 'package:hris_apps/features/finance/domain/entities/monthly_payroll_batch.dart';
import 'package:hris_apps/features/finance/domain/usecases/finalize_payroll_batch_usecase.dart';
import 'package:hris_apps/features/finance/domain/usecases/get_payroll_batches_usecase.dart';
import 'package:hris_apps/features/finance/domain/usecases/run_payroll_batch_usecase.dart';

class FinanceProvider extends ChangeNotifier {
  final GetPayrollBatchesUseCase getPayrollBatchesUseCase;
  final RunPayrollBatchUseCase runPayrollBatchUseCase;
  final FinalizePayrollBatchUseCase finalizePayrollBatchUseCase;

  FinanceProvider({
    required this.getPayrollBatchesUseCase,
    required this.runPayrollBatchUseCase,
    required this.finalizePayrollBatchUseCase,
  });

  List<MonthlyPayrollBatch> _batches = [];
  int _selectedPeriodIndex = 0;
  bool _isLoading = false;
  bool _isRunningPayroll = false;
  bool _isFinalizingPayroll = false;

  List<MonthlyPayrollBatch> get batches => _batches;
  int get selectedPeriodIndex => _selectedPeriodIndex;
  bool get isLoading => _isLoading;
  bool get isRunningPayroll => _isRunningPayroll;
  bool get isFinalizingPayroll => _isFinalizingPayroll;

  MonthlyPayrollBatch? get currentBatch =>
      _batches.isNotEmpty ? _batches[_selectedPeriodIndex] : null;

  Future<void> loadBatches() async {
    _isLoading = true;
    notifyListeners();
    try {
      _batches = await getPayrollBatchesUseCase();
      _selectedPeriodIndex = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectPeriodIndex(int index) {
    if (index >= 0 && index < _batches.length) {
      _selectedPeriodIndex = index;
      notifyListeners();
    }
  }

  Future<bool> runPayrollForCurrentPeriod() async {
    final batch = currentBatch;
    if (batch == null || _isRunningPayroll) return false;

    _isRunningPayroll = true;
    notifyListeners();
    try {
      final updated = await runPayrollBatchUseCase(batch.period);
      _batches[_selectedPeriodIndex] = updated;
      return true;
    } catch (_) {
      return false;
    } finally {
      _isRunningPayroll = false;
      notifyListeners();
    }
  }

  Future<bool> finalizeCurrentPayroll() async {
    final batch = currentBatch;
    if (batch == null || _isFinalizingPayroll) return false;

    _isFinalizingPayroll = true;
    notifyListeners();
    try {
      final updated = await finalizePayrollBatchUseCase(batch.period);
      _batches[_selectedPeriodIndex] = updated;
      return true;
    } catch (_) {
      return false;
    } finally {
      _isFinalizingPayroll = false;
      notifyListeners();
    }
  }
}
