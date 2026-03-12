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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBrandDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
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
        padding: const EdgeInsets.all(12),
        itemCount: vm.brands.length,
        itemBuilder: (context, index) {
          final brand = vm.brands[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: brand.logoUrl != null && brand.logoUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        brand.logoUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 48,
                          height: 48,
                          color: AppColors.surfaceDark,
                          child: const Icon(Icons.branding_watermark,
                              color: AppColors.textHint),
                        ),
                      ),
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.branding_watermark,
                          color: AppColors.textHint),
                    ),
              title: Text(brand.name, style: AppTextStyles.headingSm),
              subtitle: Text(
                brand.description.isNotEmpty
                    ? brand.description
                    : 'Không có mô tả',
                style: AppTextStyles.bodySm,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.primary),
                    onPressed: () => _showBrandDialog(brand: brand),
                    iconSize: 22,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => _confirmDelete(brand),
                    iconSize: 22,
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
