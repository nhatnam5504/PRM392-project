import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/feedback_model.dart';
import '../view_models/feedback_view_model.dart';

class ProductFeedbackSection extends StatefulWidget {
  final int productId;

  const ProductFeedbackSection({
    super.key,
    required this.productId,
  });

  @override
  State<ProductFeedbackSection> createState() =>
      _ProductFeedbackSectionState();
}

class _ProductFeedbackSectionState
    extends State<ProductFeedbackSection> {

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedbackViewModel>(
      builder: (context, vm, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text('Đánh giá khách hàng', style: AppTextStyles.headingSm.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(width: 12),
                if (vm.totalFeedbacks > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${vm.totalFeedbacks}',
                      style: AppTextStyles.labelBold.copyWith(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w900),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            if (vm.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3)),
              )
            else if (vm.errorMessage != null)
              _buildErrorState(vm)
            else if (vm.feedbacks.isEmpty)
              _buildEmptyState()
            else ...[
              _buildRatingSummary(vm),
              const SizedBox(height: 32),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vm.feedbacks.length,
                separatorBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: AppColors.surfaceDark.withValues(alpha: 0.5)),
                ),
                itemBuilder: (context, index) => _buildFeedbackCard(vm.feedbacks[index]),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildRatingSummary(FeedbackViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceDark),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  vm.averageRating.toStringAsFixed(1),
                  style: AppTextStyles.displayLarge.copyWith(
                    color: AppColors.textPrimary, 
                    fontWeight: FontWeight.w900,
                    fontSize: 48,
                  ),
                ),
                const SizedBox(height: 4),
                _buildStarRow(vm.averageRating, 16),
                const SizedBox(height: 12),
                Text(
                  'Dựa trên ${vm.totalFeedbacks}\nđánh giá',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold, height: 1.3),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Container(width: 1.5, height: 100, color: AppColors.borderLight, margin: const EdgeInsets.symmetric(horizontal: 24)),
          Expanded(
            flex: 3,
            child: Column(
              children: List.generate(5, (index) {
                final star = 5 - index;
                final count = vm.feedbacks.where((f) => f.rating == star).length;
                final ratio = vm.totalFeedbacks > 0 ? count / vm.totalFeedbacks : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text('$star', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900, fontSize: 11)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            backgroundColor: Colors.white,
                            color: Colors.amber,
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(FeedbackModel fb) {
    final dateFmt = DateFormat('dd/MM/yyyy');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Modern Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, const Color(0xFF22D3EE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Center(
                  child: Text(
                    fb.userName.isNotEmpty ? fb.userName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fb.userName, style: AppTextStyles.labelBold.copyWith(height: 1.1, fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStarRow(fb.rating.toDouble(), 12),
                        const SizedBox(width: 12),
                        Text(
                          dateFmt.format(fb.date), 
                          style: AppTextStyles.caption.copyWith(fontSize: 11, color: AppColors.textHint, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textHint, size: 22),
                onPressed: () {},
              ),
            ],
          ),
          if (fb.comment.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Text(
                fb.comment,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary, height: 1.6, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStarRow(double rating, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData iconData = Icons.star_rounded;
        Color iconColor = Colors.amber;
        if (index >= rating) {
          iconData = Icons.star_rounded;
          iconColor = AppColors.textHint.withValues(alpha: 0.2);
        } else if (index + 1 > rating && rating % 1 > 0) {
          iconData = Icons.star_half_rounded;
        }
        return Icon(iconData, size: size, color: iconColor);
      }),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceDark),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
            ),
            child: const Icon(Icons.rate_review_outlined, size: 40, color: AppColors.textHint),
          ),
          const SizedBox(height: 20),
          Text(
            'Chưa có đánh giá nào',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy là người đầu tiên đánh giá sản phẩm này!',
            style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(FeedbackViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 32),
          const SizedBox(height: 12),
          Text(vm.errorMessage!, style: AppTextStyles.bodySm.copyWith(color: AppColors.error)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => vm.loadFeedbacks(widget.productId),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}


