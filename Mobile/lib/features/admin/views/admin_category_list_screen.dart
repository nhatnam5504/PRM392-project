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
        title: Text(category == null ? 'Thêm danh mục' : 'Sửa danh mục'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên danh mục *',
                  hintText: 'Nhập tên danh mục',
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
              category == null ? 'Tạo' : 'Cập nhật',
              style: const TextStyle(color: Colors.white),
            ),
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
                    ? 'Tạo danh mục thành công!'
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

  Future<void> _confirmDelete(CategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: Text('Bạn có chắc muốn xoá "${category.name}"?'),
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
      final vm = context.read<AdminCategoryViewModel>();
      final success = await vm.deleteCategory(category.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(success ? 'Đã xoá danh mục' : (vm.errorMessage ?? 'Lỗi')),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminCategoryViewModel>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('THÊM MỚI', style: AppTextStyles.labelBold.copyWith(color: Colors.white)),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(vm.errorMessage!, style: AppTextStyles.bodyMd),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => vm.loadCategories(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    if (vm.categories.isEmpty) {
      return const Center(
        child: Text('Chưa có danh mục nào.', style: AppTextStyles.bodyMd),
      );
    }
    return RefreshIndicator(
      onRefresh: () => vm.loadCategories(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: vm.categories.length,
        itemBuilder: (context, index) {
          final category = vm.categories[index];
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.category_outlined, color: AppColors.primary, size: 24),
              ),
              title: Text(
                category.name,
                style: AppTextStyles.headingSm.copyWith(color: AppColors.textHeading),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  category.description.isNotEmpty ? category.description : 'Không có mô tả',
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
                    onTap: () => _showCategoryDialog(category: category),
                  ),
                  const SizedBox(width: 8),
                  _CircleIconButton(
                    icon: Icons.delete_outline_rounded,
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
