import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/brand_model.dart';
import '../view_models/admin_brand_view_model.dart';

class AdminBrandListScreen extends StatefulWidget {
  const AdminBrandListScreen({super.key});

  @override
  State<AdminBrandListScreen> createState() => _AdminBrandListScreenState();
}

class _AdminBrandListScreenState extends State<AdminBrandListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminBrandViewModel>().loadBrands();
    });
  }

  Future<void> _showBrandDialog({BrandModel? brand}) async {
    final nameController = TextEditingController(text: brand?.name ?? '');
    final descController = TextEditingController(text: brand?.description ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(brand == null ? 'Thêm thương hiệu' : 'Sửa thương hiệu', style: AppTextStyles.headingSm),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tên thương hiệu *',
                  hintText: 'Nhập tên thương hiệu',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.branding_watermark_outlined),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Mô tả',
                  hintText: 'Nhập mô tả chi tiết',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('HỦY', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(brand == null ? 'TẠO MỚI' : 'CẬP NHẬT', style: AppTextStyles.labelBold),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final vm = context.read<AdminBrandViewModel>();
      bool success;
      if (brand == null) {
        success = await vm.createBrand(
          name: nameController.text.trim(),
          description: descController.text.trim(),
        );
      } else {
        success = await vm.updateBrand(
          id: brand.id,
          name: nameController.text.trim(),
          description: descController.text.trim(),
          logoUrl: brand.logoUrl,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? (brand == null ? 'Đã thêm thương hiệu mới!' : 'Đã cập nhật thay đổi!') : (vm.errorMessage ?? 'Có lỗi xảy ra')),
            backgroundColor: success ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(BrandModel brand) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận xoá'),
        content: Text('Bạn có chắc muốn xoá thương hiệu "${brand.name}" khỏi hệ thống?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('QUAY LẠI', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('XÓA NGAY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final vm = context.read<AdminBrandViewModel>();
      final success = await vm.deleteBrand(brand.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Đã xoá thương hiệu thành công' : (vm.errorMessage ?? 'Lỗi không xác định')),
            backgroundColor: success ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminBrandViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showBrandDialog(),
          backgroundColor: AppColors.primary,
          elevation: 0,
          highlightElevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text('THÊM THƯƠNG HIỆU', style: AppTextStyles.labelBold.copyWith(color: Colors.white, letterSpacing: 0.5)),
        ),
      ),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(AdminBrandViewModel vm) {
    if (vm.isLoading && vm.brands.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null && vm.brands.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(vm.errorMessage!, style: AppTextStyles.bodyMd, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => vm.loadBrands(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
    if (vm.brands.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.branding_watermark_rounded, size: 64, color: AppColors.textHint.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text('Chưa có thương hiệu nào', style: AppTextStyles.headingSm.copyWith(color: AppColors.textHint)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => vm.loadBrands(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        itemCount: vm.brands.length,
        itemBuilder: (context, index) {
          final brand = vm.brands[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: brand.logoUrl != null && brand.logoUrl!.isNotEmpty
                      ? Image.network(
                          brand.logoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.branding_watermark_rounded, color: AppColors.textHint, size: 24),
                        )
                      : const Icon(Icons.branding_watermark_rounded, color: AppColors.textHint, size: 24),
                ),
              ),
              title: Text(brand.name, style: AppTextStyles.headingSm.copyWith(color: AppColors.textHeading, fontSize: 16)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  brand.description.isNotEmpty ? brand.description : 'Chưa có mô tả chi tiết',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CircleIconButton(
                    icon: Icons.edit_note_rounded,
                    color: AppColors.primary,
                    onTap: () => _showBrandDialog(brand: brand),
                  ),
                  const SizedBox(width: 8),
                  _CircleIconButton(
                    icon: Icons.delete_sweep_rounded,
                    color: AppColors.error,
                    onTap: () => _confirmDelete(brand),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
