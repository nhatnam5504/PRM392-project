import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/category_model.dart';
import '../view_models/admin_category_view_model.dart';

class AdminCategoryListScreen extends StatefulWidget {
  const AdminCategoryListScreen({super.key});

  @override
  State<AdminCategoryListScreen> createState() =>
      _AdminCategoryListScreenState();
}

class _AdminCategoryListScreenState extends State<AdminCategoryListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminCategoryViewModel>().loadCategories();
    });
  }

  Future<void> _showCategoryDialog({CategoryModel? category}) async {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descController =
        TextEditingController(text: category?.description ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(category == null ? 'Thêm danh mục' : 'Sửa danh mục',
            style: AppTextStyles.headingSm),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tên danh mục *',
                  hintText: 'Nhập tên danh mục',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.grid_view_rounded),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Mô tả',
                  hintText: 'Nhập mô tả danh mục',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.notes_rounded),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('HỦY',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(category == null ? 'TẠO MỚI' : 'CẬP NHẬT',
                style: AppTextStyles.labelBold),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final vm = context.read<AdminCategoryViewModel>();
      bool success;
      if (category == null) {
        success = await vm.createCategory(
          name: nameController.text.trim(),
          description: descController.text.trim(),
        );
      } else {
        success = await vm.updateCategory(
          id: category.id,
          name: nameController.text.trim(),
          description: descController.text.trim(),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? (category == null
                    ? 'Đã thêm danh mục mới!'
                    : 'Đã lưu thay đổi!')
                : (vm.errorMessage ?? 'Có lỗi xảy ra')),
            backgroundColor: success ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
    nameController.dispose();
    descController.dispose();
  }

  Future<void> _confirmDelete(CategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận xoá'),
        content: Text(
            'Bạn có chắc muốn xoá danh mục "${category.name}"? Thao tác này có thể ảnh hưởng đến các sản phẩm thuộc danh mục này.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('HỦY',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('XÓA DANH MỤC',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final vm = context.read<AdminCategoryViewModel>();
      final success = await vm.deleteCategory(category.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                success ? 'Đã xoá danh mục thành công' : (vm.errorMessage ?? 'Lỗi')),
            backgroundColor: success ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminCategoryViewModel>();

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
          onPressed: () => _showCategoryDialog(),
          backgroundColor: AppColors.primary,
          elevation: 0,
          highlightElevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text('THÊM DANH MỤC',
              style: AppTextStyles.labelBold
                  .copyWith(color: Colors.white, letterSpacing: 0.5)),
        ),
      ),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(AdminCategoryViewModel vm) {
    if (vm.isLoading && vm.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null && vm.categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(vm.errorMessage!,
                  style: AppTextStyles.bodyMd, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => vm.loadCategories(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
    if (vm.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_rounded,
                size: 64, color: AppColors.textHint.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text('Chưa có danh mục nào',
                style: AppTextStyles.headingSm
                    .copyWith(color: AppColors.textHint)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => vm.loadCategories(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        itemCount: vm.categories.length,
        itemBuilder: (context, index) {
          final category = vm.categories[index];
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.grid_view_rounded,
                    color: AppColors.primary, size: 28),
              ),
              title: Text(category.name,
                  style: AppTextStyles.headingSm
                      .copyWith(color: AppColors.textHeading, fontSize: 16)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  category.description.isNotEmpty
                      ? category.description
                      : 'Chưa có mô tả chi tiết',
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary),
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
                    onTap: () => _showCategoryDialog(category: category),
                  ),
                  const SizedBox(width: 8),
                  _CircleIconButton(
                    icon: Icons.delete_sweep_rounded,
                    color: AppColors.error,
                    onTap: () => _confirmDelete(category),
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
