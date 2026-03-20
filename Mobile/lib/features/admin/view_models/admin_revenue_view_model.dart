import 'package:flutter/foundation.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/repositories/admin_payment_repository.dart';

enum RevenueGroupBy { day, month, year }

class RevenuePoint {
  final String label;
  final double revenue;
  final int count;

  const RevenuePoint({
    required this.label,
    required this.revenue,
    required this.count,
  });
}

class AdminRevenueViewModel extends ChangeNotifier {
  final AdminPaymentRepository _repo;

  AdminRevenueViewModel({AdminPaymentRepository? repo})
      : _repo = repo ?? AdminPaymentRepository();

  List<PaymentModel> _payments = [];
  bool _isLoading = false;
  String? _errorMessage;
  RevenueGroupBy _groupBy = RevenueGroupBy.day;

  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RevenueGroupBy get groupBy => _groupBy;

  // ── Summary stats (completed only) ──
  double get totalRevenue => _completed.fold(0, (s, p) => s + p.amount);
  int get totalCompleted => _completed.length;
  int get totalPending =>
      _payments.where((p) => p.status.toUpperCase() == 'PENDING').length;
  double get avgOrderValue =>
      _completed.isEmpty ? 0 : totalRevenue / _completed.length;

  List<PaymentModel> get _completed =>
      _payments.where((p) => p.isCompleted).toList();

  // ── Chart data ──
  List<RevenuePoint> get chartPoints {
    final completed = _completed;
    if (completed.isEmpty) return [];

    final Map<String, List<PaymentModel>> grouped = {};
    for (final p in completed) {
      final key = _groupKey(p.dateTime);
      grouped.putIfAbsent(key, () => []).add(p);
    }

    final sorted = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return sorted.map((e) {
      final revenue = e.value.fold<double>(0, (s, p) => s + p.amount);
      return RevenuePoint(
        label: _displayLabel(e.key),
        revenue: revenue,
        count: e.value.length,
      );
    }).toList();
  }

  String _groupKey(DateTime dt) {
    switch (_groupBy) {
      case RevenueGroupBy.day:
        return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      case RevenueGroupBy.month:
        return '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
      case RevenueGroupBy.year:
        return '${dt.year}';
    }
  }

  String _displayLabel(String key) {
    final parts = key.split('-');
    switch (_groupBy) {
      case RevenueGroupBy.day:
        return '${parts[2]}/${parts[1]}';
      case RevenueGroupBy.month:
        return 'T${parts[1]}/${parts[0].substring(2)}';
      case RevenueGroupBy.year:
        return parts[0];
    }
  }

  Future<void> loadPayments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _payments = await _repo.getAllPayments();
      _payments.sort((a, b) => a.date.compareTo(b.date));
    } catch (e, st) {
      _errorMessage = 'Không thể tải dữ liệu: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setGroupBy(RevenueGroupBy g) {
    _groupBy = g;
    notifyListeners();
  }
}

