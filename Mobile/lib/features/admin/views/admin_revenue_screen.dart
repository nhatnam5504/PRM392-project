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
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.9),
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_graph_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'TỔNG DOANH THU',
                      style: AppTextStyles.labelBold.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 1.5,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  formatVND(vm.totalRevenue),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _HeaderStatItem(
                        label: 'Đơn hàng',
                        value: '${vm.totalCompleted}',
                        icon: Icons.shopping_bag_outlined,
                      ),
                      Container(width: 1, height: 24, color: Colors.white24),
                      _HeaderStatItem(
                        label: 'Trung bình',
                        value: _shortMoney(vm.avgOrderValue),
                        icon: Icons.analytics_outlined,
                      ),
                      Container(width: 1, height: 24, color: Colors.white24),
                      _HeaderStatItem(
                        label: 'Đang xử lý',
                        value: '${vm.totalPending}',
                        icon: Icons.timer_outlined,
                      ),
                    ],
                  ),
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
      (RevenueGroupBy.day, 'Ngày'),
      (RevenueGroupBy.month, 'Tháng'),
      (RevenueGroupBy.year, 'Năm'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Text('Phân tích thị trường', style: AppTextStyles.headingSm.copyWith(color: AppColors.textHeading, fontSize: 18)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      g.$2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                        color: isActive ? AppColors.primary : AppColors.textSecondary,
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
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.query_stats_rounded, size: 48, color: AppColors.textHint.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text('Chưa có dữ liệu giao dịch', style: AppTextStyles.bodyMd.copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
        ),
      );
    }

    final maxY = points.map((p) => p.revenue).reduce((a, b) => a > b ? a : b);
    final chartMax = (maxY * 1.2).ceilToDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 24, 20, 16),
        child: Column(
          children: [
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: chartMax,
                  minY: 0,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppColors.primary,
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final p = points[groupIndex];
                        return BarTooltipItem(
                          '${p.label}\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          children: [
                            TextSpan(
                              text: formatVND(p.revenue),
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500, fontSize: 11),
                            ),
                          ],
                        );
                      },
                    ),
                    touchCallback: (event, response) {
                      if (event is FlTapUpEvent || event is FlPanUpdateEvent) {
                        setState(() {
                          _touchedIndex = response?.spot?.touchedBarGroupIndex;
                        });
                      }
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= points.length) return const SizedBox.shrink();
                          final skip = (points.length / 5).ceil();
                          if (idx % skip != 0) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              points[idx].label,
                              style: const TextStyle(fontSize: 10, color: AppColors.textHint, fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          return Text(
                            _shortMoney(value),
                            style: const TextStyle(fontSize: 10, color: AppColors.textHint, fontWeight: FontWeight.w500),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.border.withValues(alpha: 0.1),
                      strokeWidth: 1,
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
                          width: points.length > 15 ? 8 : 16,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          gradient: LinearGradient(
                            colors: isTouched
                                ? [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)]
                                : [AppColors.primary.withValues(alpha: 0.2), AppColors.primary.withValues(alpha: 0.4)],
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
    if (recent.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Giao dịch mới nhất', style: AppTextStyles.headingSm.copyWith(color: AppColors.textHeading, fontSize: 18)),
              TextButton(
                onPressed: () {},
                child: Text('Xem tất cả', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recent.map((p) => _TransactionRow(payment: p)),
        ],
      ),
    );
  }

  String _shortMoney(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }
}

// ─── Transaction Row ────────────────────────────
class _TransactionRow extends StatelessWidget {
  final PaymentModel payment;

  const _TransactionRow({required this.payment});

  @override
  Widget build(BuildContext context) {
    final isCompleted = payment.isCompleted;
    final color = isCompleted ? AppColors.success : AppColors.warning;
    final bgOpacity = isCompleted ? 0.08 : 0.12;

    String formattedDate = '';
    try {
      final dt = payment.dateTime.toLocal();
      formattedDate = '${dt.day}/${dt.month} • ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withValues(alpha: bgOpacity),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded,
            color: color,
            size: 26,
          ),
        ),
        title: Text(
          payment.paymentMethod,
          style: AppTextStyles.labelBold.copyWith(color: AppColors.textHeading, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            formattedDate,
            style: AppTextStyles.caption.copyWith(color: AppColors.textHint, fontWeight: FontWeight.w500),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '+${formatVND(payment.amount)}',
              style: TextStyle(
                color: AppColors.textHeading,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isCompleted ? 'THÀNH CÔNG' : 'ĐANG XỬ LÝ',
                style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 9, letterSpacing: 0.5),
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
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
