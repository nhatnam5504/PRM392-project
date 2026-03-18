import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/review_model.dart';
import '../view_models/review_view_model.dart';

class EditReviewScreen extends StatefulWidget {
  final ReviewModel review;

  const EditReviewScreen({
    super.key,
    required this.review,
  });

  @override
  State<EditReviewScreen> createState() =>
      _EditReviewScreenState();
}

class _EditReviewScreenState extends State<EditReviewScreen> {
  late int _rating;
  late TextEditingController _commentController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.review.rating;
    _commentController = TextEditingController(
      text: widget.review.comment,
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Chỉnh sửa đánh giá'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đánh giá của bạn',
              style: AppTextStyles.headingSm,
            ),
            const SizedBox(height: 16),
            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      index < _rating
                          ? Icons.star
                          : Icons.star_border,
                      color: AppColors.star,
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Text(
              'Nhận xét của bạn',
              style: AppTextStyles.labelBold,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText:
                    'Chia sẻ trải nghiệm của bạn về sản phẩm...',
                alignLabelWithHint: true,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_rating > 0 &&
                            _commentController
                                .text.isNotEmpty &&
                            !_isSubmitting)
                        ? () => _submitUpdate()
                        : null,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Cập nhật'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitUpdate() async {
    if (_rating == 0) {
      _showError('Vui lòng chọn đánh giá sao');
      return;
    }

    if (_commentController.text.isEmpty) {
      _showError('Vui lòng nhập nhận xét');
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await context
        .read<ReviewViewModel>()
        .updateReview(
          reviewId: widget.review.id,
          rating: _rating,
          comment: _commentController.text.trim(),
        );

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (success) {
        _showSuccess('Cập nhật đánh giá thành công');
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            context.pop();
          }
        });
      } else {
        _showError(
          context.read<ReviewViewModel>().errorMessage ??
              'Không thể cập nhật đánh giá',
        );
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

