import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_routes.dart';

/// Màn hình xác nhận đặt hàng thành công
/// Hiển thị: thông báo thành công, mã đơn hàng, thời gian giao hàng dự kiến,
/// địa chỉ nhận hàng, nút tiếp tục mua sắm
class OrderSuccessScreen extends StatelessWidget {
  final double totalAmount; // Tổng tiền đơn hàng

  const OrderSuccessScreen({super.key, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false, // Ẩn nút back
        title: Row(
          children: [
            // Logo nhỏ
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.devices,
                color: AppColors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text(
              'TECHGEAR',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),

            // Icon thành công
            _buildSuccessIcon(),

            const SizedBox(height: AppSpacing.lg),

            // Thông báo thành công
            _buildSuccessMessage(),

            const SizedBox(height: AppSpacing.lg),

            // Chi tiết đơn hàng
            _buildOrderDetails(),

            const SizedBox(height: AppSpacing.lg),

            // Địa chỉ nhận hàng
            _buildDeliveryAddress(),

            const SizedBox(height: AppSpacing.xl),

            // Nút hành động
            _buildActionButtons(context),

            const SizedBox(height: AppSpacing.lg),

            // Thông tin hỗ trợ
            _buildSupportInfo(),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  /// Xây dựng icon dấu tick thành công
  Widget _buildSuccessIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_circle, color: AppColors.success, size: 60),
    );
  }

  /// Xây dựng phần thông báo thành công
  Widget _buildSuccessMessage() {
    return Column(
      children: [
        // Tiêu đề
        const Text(
          'Đặt hàng thành công!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Mô tả
        Text(
          'Cảm ơn bạn đã tin tưởng lựa chọn TechGear.\nĐơn hàng của bạn đang được xử lý.',
          style: AppTextStyles.subtitle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Xây dựng phần chi tiết đơn hàng
  Widget _buildOrderDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Mã đơn hàng
          _buildDetailRow(
            icon: Icons.receipt_long,
            label: 'Mã đơn hàng',
            value: '#TG-9948210',
            valueColor: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.border),
          const SizedBox(height: AppSpacing.md),

          // Ngày giao hàng dự kiến
          _buildDetailRow(
            icon: Icons.local_shipping,
            label: 'Dự kiến giao hàng',
            value: 'Thứ Năm, 24 Tháng 10, 2024',
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.border),
          const SizedBox(height: AppSpacing.md),

          // Tổng tiền
          _buildDetailRow(
            icon: Icons.payments,
            label: 'Tổng thanh toán',
            value: _formatPrice(totalAmount),
            valueColor: AppColors.priceNew,
          ),
        ],
      ),
    );
  }

  /// Xây dựng một dòng chi tiết (icon + nhãn + giá trị)
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        // Icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        // Nội dung
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.title.copyWith(
                  fontSize: 14,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Xây dựng phần địa chỉ nhận hàng
  Widget _buildDeliveryAddress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Địa chỉ nhận hàng',
                style: AppTextStyles.title.copyWith(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Tên người nhận
          Text(
            'Nguyễn Văn A',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Địa chỉ chi tiết
          Text(
            'Số 123 Đường ABC, Phường XYZ\nQuận 1\nTP. Hồ Chí Minh',
            style: AppTextStyles.subtitle.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  /// Xây dựng các nút hành động
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Nút tiếp tục mua sắm
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // Quay về trang chủ, xóa tất cả route trước đó
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              elevation: 2,
            ),
            child: const Text('Tiếp tục mua sắm', style: AppTextStyles.button),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Nút xem chi tiết đơn hàng
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              // TODO: Chuyển đến trang chi tiết đơn hàng
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: const Text(
              'Xem chi tiết đơn hàng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  /// Xây dựng phần thông tin hỗ trợ
  Widget _buildSupportInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Mọi thắc mắc liên hệ: ', style: AppTextStyles.caption),
        const Icon(Icons.phone, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          '1900 1234',
          style: AppTextStyles.body.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Format giá tiền theo định dạng VNĐ
  String _formatPrice(double price) {
    final formatted = price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
    return '${formatted}đ';
  }
}
