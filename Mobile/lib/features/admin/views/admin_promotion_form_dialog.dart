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
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85, maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.initialPromotion != null ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.initialPromotion != null ? 'Chỉnh sửa Khuyến mãi' : 'Thêm Khuyến mãi mới',
                    style: AppTextStyles.headingSm.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(_codeController, 'Mã khuyến mãi', 'Ví dụ: SUMMER2024', Icons.qr_code_rounded),
                      const SizedBox(height: 16),
                      _buildTextField(_descriptionController, 'Mô tả chi tiết', 'Nội dung chương trình...', Icons.description_outlined, maxLines: 2),
                      const SizedBox(height: 16),
                      _buildDropdownType(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_discountValueController, 'Giá trị giảm', '0', Icons.local_offer_outlined, isNumber: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField(_quantityController, 'Số lượng lượt', '0', Icons.numbers_rounded, isNumber: true)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_minOrderAmountController, 'Đơn tối thiểu', '0', Icons.shopping_bag_outlined, isNumber: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField(_maxDiscountValueController, 'Giảm tối đa', '0', Icons.vertical_align_top_rounded, isNumber: true)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildDateSection(),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt_rounded, color: Colors.amber, size: 20),
                            const SizedBox(width: 12),
                            const Expanded(child: Text('Kích hoạt khuyến mãi ngay', style: AppTextStyles.bodyMd)),
                            Switch.adaptive(
                              value: _active,
                              onChanged: (val) => setState(() => _active = val),
                              activeColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      if (_selectedType == PromotionType.bogo) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'SẢN PHẨM ÁP DỤNG (BOGO)',
                              style: AppTextStyles.labelBold.copyWith(color: AppColors.primary, fontSize: 11, letterSpacing: 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildProductSelector(vm.allProducts),
                      ],
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: vm.isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: vm.isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                              : Text(
                                  widget.initialPromotion != null ? 'LƯU THAY ĐỔI' : 'TẠO KHUYẾN MÃI',
                                  style: AppTextStyles.labelBold.copyWith(fontSize: 15, letterSpacing: 1),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: AppTextStyles.labelBold.copyWith(color: AppColors.textSecondary, fontSize: 12)),
        ),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textHint.withValues(alpha: 0.5)),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: AppColors.surfaceDark.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Bắt buộc nhập';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('Loại khuyến mãi', style: AppTextStyles.labelBold.copyWith(color: AppColors.textSecondary, fontSize: 12)),
        ),
        DropdownButtonFormField<PromotionType>(
          value: _selectedType,
          style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600, color: AppColors.textHeading),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: AppColors.surfaceDark.withValues(alpha: 0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: PromotionType.values.map((type) {
            String label = type == PromotionType.percentage ? 'GIẢM THEO %' : (type == PromotionType.money ? 'GIẢM TIỀN MẶT' : 'MUA 1 TẶNG 1 (BOGO)');
            return DropdownMenuItem(
              value: type,
              child: Text(label),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedType = val);
          },
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text('THỜI HẠN CHƯƠNG TRÌNH', style: AppTextStyles.labelBold.copyWith(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1)),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: _DateTile(
                  label: 'BẮT ĐẦU',
                  date: dateFormat.format(_startDate),
                  icon: Icons.calendar_today_rounded,
                  onTap: () => _selectDate(context, true),
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.divider.withValues(alpha: 0.5)),
              Expanded(
                child: _DateTile(
                  label: 'KẾT THÚC',
                  date: dateFormat.format(_endDate),
                  icon: Icons.event_available_rounded,
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductSelector(List<ProductModel> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text('SẢN PHẨM ÁP DỤNG', style: AppTextStyles.labelBold.copyWith(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1)),
        ),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.2)),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final isSelected = _selectedProductIds.contains(product.id);
              return CheckboxListTile(
                value: isSelected,
                title: Text(product.name, style: AppTextStyles.bodyMd),
                subtitle: Text(product.categoryName, style: AppTextStyles.bodySm),
                onChanged: (val) {
                  setState(() {
                    if (val == true) _selectedProductIds.add(product.id);
                    else _selectedProductIds.remove(product.id);
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String date;
  final IconData icon;
  final VoidCallback onTap;

  const _DateTile({
    required this.label,
    required this.date,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelSm.copyWith(color: AppColors.textHint, fontSize: 9)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(date, style: AppTextStyles.labelBold.copyWith(fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
