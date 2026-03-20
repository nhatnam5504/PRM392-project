import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/product_model.dart';
import '../view_models/admin_product_view_model.dart';

class AdminProductFormScreen extends StatefulWidget {
  final int? productId;

  const AdminProductFormScreen({super.key, this.productId});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  int? _selectedCategoryId;
  int? _selectedBrandId;
  int? _selectedVersionId;
  bool _active = true;
  String? _imagePath;
  ProductModel? _editingProduct;

  bool get isEditing => widget.productId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final vm = context.read<AdminProductViewModel>();
      await vm.loadFormData();
      if (!mounted) return;
      if (isEditing) {
        _loadExistingProduct(vm);
      }
    });
  }

  void _loadExistingProduct(AdminProductViewModel vm) {
    try {
      final product = vm.products.firstWhere((p) => p.id == widget.productId);
      _editingProduct = product;
      _nameController.text = product.name;
      _descController.text = product.description;
      _priceController.text = product.price.toInt().toString();
      _quantityController.text = product.stockQuantity.toString();
      _active = product.active;

      // Match category: try ID first, fallback to name
      final catId = product.categoryId != 0 ? product.categoryId : null;
      final matchedCat = catId != null
          ? vm.categories.where((c) => c.id == catId).firstOrNull
          : vm.categories
              .where((c) =>
                  c.name.toLowerCase().trim() ==
                  product.categoryName.toLowerCase().trim())
              .firstOrNull;

      // Match brand by name
      final matchedBrand = vm.brands
          .where((b) =>
              b.name.toLowerCase().trim() ==
              product.brandName.toLowerCase().trim())
          .firstOrNull;

      // Match version by name
      final matchedVersion = vm.versions
          .where((v) =>
              v.versionName.toLowerCase().trim() ==
              product.versionName.toLowerCase().trim())
          .firstOrNull;

      setState(() {
        _selectedCategoryId = matchedCat?.id ?? catId;
        _selectedBrandId = matchedBrand?.id;
        _selectedVersionId = matchedVersion?.id;
      });
    } catch (_) {
      // Product not found in local list
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _imagePageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null ||
        _selectedBrandId == null ||
        _selectedVersionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Vui lòng chọn đầy đủ danh mục, thương hiệu và phiên bản'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final vm = context.read<AdminProductViewModel>();
    bool success;

    if (isEditing) {
      success = await vm.updateProduct(
        id: widget.productId!,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: int.parse(_priceController.text.trim()),
        stockQuantity: int.parse(_quantityController.text.trim()),
        active: _active,
        versionId: _selectedVersionId!,
        brandId: _selectedBrandId!,
        categoryId: _selectedCategoryId!,
        imagePath: _imagePath,
      );
    } else {
      success = await vm.createProduct(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: int.parse(_priceController.text.trim()),
        stockQuantity: int.parse(_quantityController.text.trim()),
        active: _active,
        versionId: _selectedVersionId!,
        brandId: _selectedBrandId!,
        categoryId: _selectedCategoryId!,
        imagePath: _imagePath,
      );
    }

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing
              ? 'Cập nhật sản phẩm thành công!'
              : 'Tạo sản phẩm thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Có lỗi xảy ra'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminProductViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa sản phẩm' : 'Thêm sản phẩm'),
        centerTitle: true,
      ),
      body: vm.isLoading && vm.categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image picker
                    _buildImagePicker(),
                    const SizedBox(height: 20),

                    // Name
                    _buildLabel('Tên sản phẩm *'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tên sản phẩm',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Vui lòng nhập tên'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _buildLabel('Mô tả'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập mô tả sản phẩm',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Price & Quantity
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Giá (VNĐ) *'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _priceController,
                                decoration: const InputDecoration(
                                  hintText: '0',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Nhập giá';
                                  }
                                  if (int.tryParse(v.trim()) == null) {
                                    return 'Giá không hợp lệ';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Số lượng *'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _quantityController,
                                decoration: const InputDecoration(
                                  hintText: '0',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Nhập SL';
                                  }
                                  if (int.tryParse(v.trim()) == null) {
                                    return 'SL không hợp lệ';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Category
                    _buildLabel('Danh mục *'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        hintText: 'Chọn danh mục',
                      ),
                      items: vm.categories
                          .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                    ),
                    const SizedBox(height: 16),

                    // Brand
                    _buildLabel('Thương hiệu *'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _selectedBrandId,
                      decoration: const InputDecoration(
                        hintText: 'Chọn thương hiệu',
                      ),
                      items: vm.brands
                          .map((b) => DropdownMenuItem(
                                value: b.id,
                                child: Text(b.name),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedBrandId = v),
                    ),
                    const SizedBox(height: 16),

                    // Version
                    _buildLabel('Phiên bản *'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _selectedVersionId,
                      decoration: const InputDecoration(
                        hintText: 'Chọn phiên bản',
                      ),
                      items: vm.versions
                          .map((v) => DropdownMenuItem(
                                value: v.id,
                                child: Text(v.versionName),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedVersionId = v),
                    ),
                    const SizedBox(height: 16),

                    // Active toggle
                    SwitchListTile(
                      title: const Text('Trạng thái bán'),
                      subtitle: Text(
                        _active ? 'Đang bán' : 'Ngừng bán',
                        style: AppTextStyles.bodySm.copyWith(
                          color: _active ? AppColors.success : AppColors.error,
                        ),
                      ),
                      value: _active,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _active = v),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 24),

                    // Submit
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: vm.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: vm.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isEditing ? 'Cập nhật' : 'Tạo sản phẩm',
                                style: AppTextStyles.buttonLg,
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: AppTextStyles.labelBold);
  }

  final PageController _imagePageController = PageController();
  int _currentImagePage = 0;

  Widget _buildImagePicker() {
    // If user picked a new local image, show it
    if (_imagePath != null) {
      return GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(_imagePath!),
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    // If editing and product has images, show gallery
    if (_editingProduct != null && _editingProduct!.imageUrls.isNotEmpty) {
      final imageUrls = _editingProduct!.imageUrls;
      return Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      controller: _imagePageController,
                      itemCount: imageUrls.length,
                      onPageChanged: (index) {
                        setState(() => _currentImagePage = index);
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          imageUrls[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _emptyImagePlaceholder(),
                        );
                      },
                    ),
                    // Counter badge
                    if (imageUrls.length > 1)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_currentImagePage + 1}/${imageUrls.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    // Camera overlay hint
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Dot indicators
          if (imageUrls.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  imageUrls.length,
                  (index) {
                    final isActive = index == _currentImagePage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: isActive ? 20 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      );
    }

    // No images at all - show empty placeholder
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: _emptyImagePlaceholder(),
      ),
    );
  }

  Widget _emptyImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_photo_alternate,
            size: 48, color: AppColors.textHint),
        const SizedBox(height: 8),
        Text(
          'Chọn ảnh sản phẩm',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textHint),
        ),
      ],
    );
  }
}
