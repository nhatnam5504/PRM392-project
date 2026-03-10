import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_routes.dart';
import '../data/sample_data.dart';
import '../widgets/category_item.dart';
import '../widgets/custom_text_field.dart';

/// Màn hình trang chủ
/// Bao gồm: thanh tìm kiếm, banner giới thiệu, danh mục nổi bật,
/// phần đăng ký nhận ưu đãi
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với logo và thanh tìm kiếm
              _buildHeader(context),

              // Banner chính
              _buildBanner(context),

              const SizedBox(height: AppSpacing.lg),

              // Phần danh mục nổi bật
              _buildCategorySection(context),

              const SizedBox(height: AppSpacing.lg),

              // Phần đăng ký nhận ưu đãi
              _buildPromotionSection(),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  /// Xây dựng phần header với logo TECHGEAR và thanh tìm kiếm
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.white,
      child: Column(
        children: [
          // Logo
          Row(
            children: [
              // Icon logo nhỏ
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.devices,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Tên thương hiệu
              const Text(
                'TECHGEAR',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              // Icon thông báo
              IconButton(
                onPressed: () {},
                icon: const Badge(
                  smallSize: 8,
                  child: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Thanh tìm kiếm
          CustomTextField(
            hintText: 'Tìm kiếm phụ kiện (vd: sạc nhanh, ốp lưng...)',
            prefixIcon: Icons.search,
            onChanged: (value) {
              // TODO: Xử lý tìm kiếm sản phẩm
            },
          ),
        ],
      ),
    );
  }

  /// Xây dựng banner giới thiệu chính
  Widget _buildBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề banner
          const Text(
            'Phụ kiện công nghệ\nchính hãng',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Mô tả ngắn
          Text(
            'Trải nghiệm đỉnh cao cùng các\nthiết bị công nghệ hiện đại nhất',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.white.withOpacity(0.85),
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Nút "Khám phá ngay"
          ElevatedButton(
            onPressed: () {
              // Chuyển đến trang danh mục sạc dự phòng
              Navigator.pushNamed(
                context,
                AppRoutes.category,
                arguments: 'sac-du-phong',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
            ),
            child: const Text(
              'Khám phá ngay',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng phần danh mục nổi bật
  Widget _buildCategorySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề phần
          const Text('DANH MỤC NỔI BẬT', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.md),
          // Lưới danh mục 3 cột
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
            ),
            itemCount: SampleData.categories.length,
            itemBuilder: (context, index) {
              final category = SampleData.categories[index];
              return CategoryItem(
                category: category,
                onTap: () {
                  // Chuyển đến trang danh mục tương ứng
                  Navigator.pushNamed(
                    context,
                    AppRoutes.category,
                    arguments: category.id,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Xây dựng phần đăng ký nhận ưu đãi
  Widget _buildPromotionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Icon khuyến mãi
          const Icon(Icons.local_offer, color: AppColors.accent, size: 36),
          const SizedBox(height: AppSpacing.sm),
          // Tiêu đề
          const Text(
            'Đừng bỏ lỡ các ưu đãi\nđộc quyền!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          // Mô tả
          Text(
            'Đăng ký để nhận thông tin khuyến mãi mới nhất\nvà mã giảm giá cho đơn hàng đầu tiên',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          // Ô nhập email + nút gửi
          Row(
            children: [
              // Ô nhập email
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: TextField(
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      hintText: 'Địa chỉ email của bạn',
                      hintStyle: AppTextStyles.caption,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Nút gửi
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Xử lý đăng ký email nhận khuyến mãi
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  child: const Text('Gửi ngay'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
