import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/promotion_model.dart';
import '../../../data/models/product_model.dart';
import '../view_models/admin_promotion_view_model.dart';

class AdminPromotionFormDialog extends StatefulWidget {
  final PromotionModel? initialPromotion;
  const AdminPromotionFormDialog({super.key, this.initialPromotion});

  @override
  State<AdminPromotionFormDialog> createState() => _AdminPromotionFormDialogState();
}

class _AdminPromotionFormDialogState extends State<AdminPromotionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _maxDiscountValueController = TextEditingController();
  final _minOrderAmountController = TextEditingController();
  final _quantityController = TextEditingController();
  
  PromotionType _selectedType = PromotionType.money;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _active = true;
  List<int> _selectedProductIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialPromotion != null) {
      final p = widget.initialPromotion!;
      _codeController.text = p.code;
      _descriptionController.text = p.description;
      _discountValueController.text = p.discountValue.toString();
      _maxDiscountValueController.text = p.maxDiscountValue.toString();
      _minOrderAmountController.text = p.minOrderAmount.toString();
      _quantityController.text = p.quantity.toString();
      _selectedType = p.type;
      _startDate = p.startDate;
      _endDate = p.endDate;
      _active = p.active;
      _selectedProductIds = List<int>.from(p.applicableProductIds ?? []);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminPromotionViewModel>().loadAllProducts();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _descriptionController.dispose();
    _discountValueController.dispose();
    _maxDiscountValueController.dispose();
    _minOrderAmountController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final promotion = PromotionModel(
      id: widget.initialPromotion?.id ?? 0,
      code: _codeController.text,
      description: _descriptionController.text,
      type: _selectedType,
      discountValue: double.tryParse(_discountValueController.text) ?? 0,
      maxDiscountValue: double.tryParse(_maxDiscountValueController.text) ?? 0,
      minOrderAmount: double.tryParse(_minOrderAmountController.text) ?? 0,
      startDate: _startDate,
      endDate: _endDate,
      active: _active,
      quantity: int.tryParse(_quantityController.text) ?? 0,
      applicableProductIds: _selectedType == PromotionType.bogo ? _selectedProductIds : null,
    );

    final vm = context.read<AdminPromotionViewModel>();
    final bool success;
    if (widget.initialPromotion != null) {
      success = await vm.updatePromotion(promotion);
    } else {
      success = await vm.createPromotion(promotion);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.initialPromotion != null
                ? 'Cập nhật khuyến mãi thành công'
                : 'Tạo khuyến mãi thành công'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.errorMessage ?? 'Có lỗi xảy ra'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminPromotionViewModel>();
    
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.initialPromotion != null
                      ? 'Chỉnh sửa Khuyến mãi'
                      : 'Thêm Khuyến mãi',
                  style: AppTextStyles.headingSm,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildTextField(_codeController, 'Mã khuyến mãi', 'VD: KM100', Icons.code),
                      const SizedBox(height: 12),
                      _buildTextField(_descriptionController, 'Mô tả', 'Mô tả chi tiết', Icons.description, maxLines: 2),
                      const SizedBox(height: 12),
                      _buildDropdownType(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_discountValueController, 'Giá trị giảm', '0', Icons.money, isNumber: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField(_quantityController, 'Số lượng', '0', Icons.confirmation_number, isNumber: true)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_minOrderAmountController, 'Đơn hàng tối thiểu', '0', Icons.shopping_bag, isNumber: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField(_maxDiscountValueController, 'Giảm tối đa', '0', Icons.arrow_upward, isNumber: true)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDateSection(),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Kích hoạt ngay', style: AppTextStyles.bodyMd),
                        value: _active,
                        onChanged: (val) => setState(() => _active = val),
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_selectedType == PromotionType.bogo) ...[
                        const SizedBox(height: 16),
                        const Text('Sản phẩm áp dụng (BOGO)', style: AppTextStyles.labelBold),
                        const SizedBox(height: 8),
                        _buildProductSelector(vm.allProducts),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: vm.isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: vm.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  widget.initialPromotion != null
                                      ? 'LƯU THAY ĐỔI'
                                      : 'LƯU KHUYẾN MÃI',
                                  style: AppTextStyles.labelBold,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Bắt buộc';
        return null;
      },
    );
  }

  Widget _buildDropdownType() {
    return DropdownButtonFormField<PromotionType>(
      value: _selectedType,
      decoration: InputDecoration(
        labelText: 'Loại khuyến mãi',
        prefixIcon: const Icon(Icons.category, color: AppColors.primary, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
      items: PromotionType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.name.toUpperCase()),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedType = val);
      },
    );
  }

  Widget _buildDateSection() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Thời hạn áp dụng', style: AppTextStyles.labelBold),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, true),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('Bắt đầu', style: AppTextStyles.labelSm),
                      Text(dateFormat.format(_startDate), style: AppTextStyles.bodyMd),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, false),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('Kết thúc', style: AppTextStyles.labelSm),
                      Text(dateFormat.format(_endDate), style: AppTextStyles.bodyMd),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductSelector(List<ProductModel> products) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final isSelected = _selectedProductIds.contains(product.id);
          return CheckboxListTile(
            title: Text(product.name, style: AppTextStyles.bodySm),
            secondary: product.imageUrls.isNotEmpty 
              ? Image.network(product.imageUrls.first, width: 24, height: 24, fit: BoxFit.cover)
              : const Icon(Icons.image, size: 24),
            value: isSelected,
            activeColor: AppColors.primary,
            dense: true,
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _selectedProductIds.add(product.id);
                } else {
                  _selectedProductIds.remove(product.id);
                }
              });
            },
          );
        },
      ),
    );
  }
}
