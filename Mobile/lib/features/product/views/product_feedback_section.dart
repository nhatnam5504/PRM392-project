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
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đánh giá sản phẩm',
                  style: AppTextStyles.headingSm,
                ),
                if (vm.totalFeedbacks > 0)
                  Text(
                    '(${vm.totalFeedbacks})',
                    style:
                        AppTextStyles.bodyMd.copyWith(
                      color:
                          AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (vm.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 24,
                ),
                child: Center(
                  child:
                      CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            else if (vm.errorMessage != null)
              _buildErrorState(vm)
            else if (vm.feedbacks.isEmpty)
              _buildEmptyState()
            else ...[
              _buildRatingSummary(vm),
              const SizedBox(height: 16),
              ...vm.feedbacks.map(
                (f) => _buildFeedbackCard(f),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildRatingSummary(
    FeedbackViewModel vm,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                vm.averageRating.toStringAsFixed(1),
                style: AppTextStyles.displayLarge
                    .copyWith(
                  color: AppColors.star,
                ),
              ),
              const SizedBox(height: 4),
              _buildStarRow(vm.averageRating, 18),
              const SizedBox(height: 4),
              Text(
                '${vm.totalFeedbacks} đánh giá',
                style: AppTextStyles.bodySm,
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final star = 5 - index;
                final count = vm.feedbacks
                    .where(
                      (f) => f.rating == star,
                    )
                    .length;
                final ratio =
                    vm.totalFeedbacks > 0
                        ? count /
                            vm.totalFeedbacks
                        : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 4,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: AppTextStyles.bodySm,
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star,
                        size: 12,
                        color: AppColors.star,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child:
                            LinearProgressIndicator(
                          value: ratio,
                          backgroundColor:
                              AppColors.border,
                          color: AppColors.star,
                          minHeight: 6,
                          borderRadius:
                              BorderRadius.circular(
                            3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 20,
                        child: Text(
                          '$count',
                          style:
                              AppTextStyles.bodySm,
                          textAlign:
                              TextAlign.right,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    AppColors.primary
                        .withValues(alpha: 0.15),
                child: Text(
                  fb.userName.isNotEmpty
                      ? fb.userName[0]
                          .toUpperCase()
                      : '?',
                  style: AppTextStyles.labelBold
                      .copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      fb.userName,
                      style:
                          AppTextStyles.labelBold,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFmt.format(fb.date),
                      style: AppTextStyles.bodySm,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildStarRow(
            fb.rating.toDouble(),
            16,
          ),
          if (fb.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              fb.comment,
              style: AppTextStyles.bodyMd,
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
        if (index < rating.floor()) {
          return Icon(
            Icons.star,
            size: size,
            color: AppColors.star,
          );
        } else if (index < rating.ceil() &&
            rating % 1 >= 0.5) {
          return Icon(
            Icons.star_half,
            size: size,
            color: AppColors.star,
          );
        } else {
          return Icon(
            Icons.star_border,
            size: size,
            color: AppColors.star,
          );
        }
      }),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 24,
      ),
      child: const Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 40,
            color: AppColors.textHint,
          ),
          SizedBox(height: 8),
          Text(
            'Chưa có đánh giá nào',
            style: AppTextStyles.bodyMd,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(FeedbackViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ),
      child: Column(
        children: [
          Text(
            vm.errorMessage!,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => vm.loadFeedbacks(
              widget.productId,
            ),
            child: Text(
              'Thử lại',
              style: AppTextStyles.labelBold
                  .copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

