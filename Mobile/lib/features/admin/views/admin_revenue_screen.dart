import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/format_price.dart';
import '../../../data/models/payment_model.dart';
import '../view_models/admin_revenue_view_model.dart';

class AdminRevenueScreen extends StatefulWidget {
  const AdminRevenueScreen({super.key});

  @override
  State<AdminRevenueScreen> createState() => _AdminRevenueScreenState();
}

class _AdminRevenueScreenState extends State<AdminRevenueScreen> {
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminRevenueViewModel>().loadPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminRevenueViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 56, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(vm.errorMessage!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: vm.loadPayments,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: vm.loadPayments,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header gradient ──
                _buildHeader(vm),

                // ── Group selector ──
                _buildGroupSelector(vm),

                // ── Chart ──
                _buildChart(vm),

                // ── Recent transactions ──
                _buildRecentList(vm),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Header Stats ───────────────────────────────
  Widget _buildHeader(AdminRevenueViewModel vm) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0891B2), Color(0xFF06B6D4), Color(0xFF22D3EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0891B2).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_graph_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'TỔNG DOANH THU',
                      style: AppTextStyles.labelBold.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  formatVND(vm.totalRevenue),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _HeaderStatItem(
                      label: 'Đơn hàng',
                      value: '${vm.totalCompleted}',
                      icon: Icons.shopping_bag_outlined,
                    ),
                    Container(width: 1, height: 24, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 16)),
                    _HeaderStatItem(
                      label: 'Trung bình',
                      value: _shortMoney(vm.avgOrderValue),
                      icon: Icons.analytics_outlined,
                    ),
                    Container(width: 1, height: 24, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 16)),
                    _HeaderStatItem(
                      label: 'Đang xử lý',
                      value: '${vm.totalPending}',
                      icon: Icons.timer_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Group By Selector ──────────────────────────
  Widget _buildGroupSelector(AdminRevenueViewModel vm) {
    final groups = [
      (RevenueGroupBy.day, 'Theo ngày'),
      (RevenueGroupBy.month, 'Theo tháng'),
      (RevenueGroupBy.year, 'Theo năm'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Text('Biểu đồ doanh thu',
              style: AppTextStyles.labelBold),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: groups.map((g) {
                final isActive = vm.groupBy == g.$1;
                return GestureDetector(
                  onTap: () {
                    setState(() => _touchedIndex = null);
                    vm.setGroupBy(g.$1);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      g.$2,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bar Chart ──────────────────────────────────
  Widget _buildChart(AdminRevenueViewModel vm) {
    final points = vm.chartPoints;
    if (points.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Text('Chưa có dữ liệu hoàn tất'),
        ),
      );
    }

    final maxY = points.map((p) => p.revenue).reduce((a, b) => a > b ? a : b);
    final chartMax = (maxY * 1.25).ceilToDouble();

    // Show tooltip above touched bar
    String? tooltipText;
    if (_touchedIndex != null &&
        _touchedIndex! >= 0 &&
        _touchedIndex! < points.length) {
      final p = points[_touchedIndex!];
      tooltipText =
          '${p.label}\n${formatVND(p.revenue)}\n${p.count} đơn';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tooltipText != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tooltipText,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: chartMax,
                  minY: 0,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.transparent,
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 0,
                      getTooltipItem: (_, __, ___, ____) => null,
                    ),
                    touchCallback: (event, response) {
                      if (event is FlTapUpEvent ||
                          event is FlPanUpdateEvent) {
                        setState(() {
                          _touchedIndex =
                              response?.spot?.touchedBarGroupIndex;
                        });
                      }
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= points.length) {
                            return const SizedBox.shrink();
                          }
                          // Show every label or skip if too many
                          final skip = (points.length / 6).ceil();
                          if (skip > 1 && idx % skip != 0) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              points[idx].label,
                              style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textHint,
                                  fontWeight: FontWeight.w500),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 52,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          return Text(
                            _shortMoney(value),
                            style: const TextStyle(
                                fontSize: 9, color: AppColors.textHint),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.border.withValues(alpha: 0.6),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(points.length, (i) {
                    final isTouched = _touchedIndex == i;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: points[i].revenue,
                          width: points.length > 15 ? 8 : 14,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)),
                          gradient: LinearGradient(
                            colors: isTouched
                                ? [
                                    const Color(0xFF0891B2),
                                    const Color(0xFF0D1B5E),
                                  ]
                                : [
                                    const Color(0xFF38BDF8),
                                    const Color(0xFF0891B2),
                                  ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Recent Transactions ───────────────────────
  Widget _buildRecentList(AdminRevenueViewModel vm) {
    final recent = vm.payments.reversed.take(10).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Giao dịch gần đây',
                  style: AppTextStyles.labelBold),
              const Spacer(),
              Text('${vm.payments.length} giao dịch',
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textHint)),
            ],
          ),
          const SizedBox(height: 10),
          ...recent.map((p) => _TransactionRow(payment: p)),
        ],
      ),
    );
  }

  String _shortMoney(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

// ─── Header Stat Chip ───────────────────────────

// ─── Transaction Row ────────────────────────────
class _TransactionRow extends StatelessWidget {
  final PaymentModel payment;

  const _TransactionRow({required this.payment});

  @override
  Widget build(BuildContext context) {
    final isCompleted = payment.isCompleted;
    final color = isCompleted ? AppColors.success : AppColors.warning;
    final label = isCompleted ? 'Thành công' : 'Chờ xử lý';

    String formattedDate = '';
    try {
      final dt = payment.dateTime.toLocal();
      formattedDate = '${dt.day}/${dt.month}/${dt.year} • ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isCompleted ? Icons.add_rounded : Icons.history_rounded,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          payment.paymentMethod,
          style: AppTextStyles.labelBold.copyWith(color: AppColors.textHeading),
        ),
        subtitle: Text(
          formattedDate,
          style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '+${formatVND(payment.amount)}',
              style: AppTextStyles.labelBold.copyWith(color: AppColors.textHeading, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HeaderStatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.white70),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
