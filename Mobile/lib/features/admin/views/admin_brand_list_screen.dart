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
    final descController =
        TextEditingController(text: brand?.description ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(brand == null ? 'Thêm thương hiệu' : 'Sửa thương hiệu'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên thương hiệu *',
                  hintText: 'Nhập tên thương hiệu',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  hintText: 'Nhập mô tả',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              brand == null ? 'Tạo' : 'Cập nhật',
              style: const TextStyle(color: Colors.white),
            ),
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
            content: Text(success
                ? (brand == null
                    ? 'Tạo thương hiệu thành công!'
                    : 'Cập nhật thành công!')
                : (vm.errorMessage ?? 'Có lỗi xảy ra')),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
    nameController.dispose();
    descController.dispose();
  }

  Future<void> _confirmDelete(BrandModel brand) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: Text('Bạn có chắc muốn xoá "${brand.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xoá'),
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
            content: Text(
                success ? 'Đã xoá thương hiệu' : (vm.errorMessage ?? 'Lỗi')),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminBrandViewModel>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBrandDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('THÊM MỚI', style: AppTextStyles.labelBold.copyWith(color: Colors.white)),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(vm.errorMessage!, style: AppTextStyles.bodyMd),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => vm.loadBrands(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    if (vm.brands.isEmpty) {
      return const Center(
        child: Text('Chưa có thương hiệu nào.', style: AppTextStyles.bodyMd),
      );
    }
    return RefreshIndicator(
      onRefresh: () => vm.loadBrands(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: vm.brands.length,
        itemBuilder: (context, index) {
          final brand = vm.brands[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryShadow.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: brand.logoUrl != null && brand.logoUrl!.isNotEmpty
                      ? Image.network(
                          brand.logoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.branding_watermark_outlined,
                            color: AppColors.textHint,
                          ),
                        )
                      : const Icon(
                          Icons.branding_watermark_outlined,
                          color: AppColors.textHint,
                        ),
                ),
              ),
              title: Text(
                brand.name,
                style: AppTextStyles.headingSm.copyWith(color: AppColors.textHeading),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  brand.description.isNotEmpty ? brand.description : 'Không có mô tả',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CircleIconButton(
                    icon: Icons.edit_rounded,
                    color: AppColors.primary,
                    onTap: () => _showBrandDialog(brand: brand),
                  ),
                  const SizedBox(width: 8),
                  _CircleIconButton(
                    icon: Icons.delete_outline_rounded,
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
      color: color.withValues(alpha: 0.1),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
