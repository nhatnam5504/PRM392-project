import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/format_price.dart';
import '../../../data/models/cart_item_model.dart';
import '../../deals/view_models/deals_view_model.dart';
import '../../profile/view_models/profile_view_model.dart';
import '../../checkout/view_models/checkout_view_model.dart';
import '../view_models/cart_view_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final cartVm = context.read<CartViewModel>();
    final profileVm = context.read<ProfileViewModel>();
    final dealsVm = context.read<DealsViewModel>();

    if (profileVm.user == null) {
      profileVm.loadProfile();
    }
    _nameController.text = profileVm.user?.name ?? '';
    
    cartVm.loadCart();
    if (dealsVm.promotions.isEmpty) {
      dealsVm.loadDeals();
    }
  }

  void _syncOrderInfo(CartViewModel vm) {
    vm.setOrderInfo(
      recipientName: _nameController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
      note: _noteController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text('Giỏ hàng', style: AppTextStyles.headingMd),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
              onPressed: () => context.pop(),
            ),
            actions: [
              if (!vm.isEmpty)
                TextButton(
                  onPressed: () => _showClearDialog(vm),
                  child: Text(
                    'Xóa hết',
                    style: AppTextStyles.labelBold.copyWith(color: AppColors.error, fontSize: 13),
                  ),
                ),
            ],
          ),
          body: vm.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : vm.isEmpty
                  ? _buildEmptyCart()
                  : _buildCartContent(vm),
          bottomNavigationBar: vm.isEmpty ? null : _buildBottom(vm),
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.textHint),
          ),
          const SizedBox(height: 24),
          const Text('Giỏ hàng của bạn đang trống', style: AppTextStyles.headingSm),
          const SizedBox(height: 8),
          Text('Có vẻ như bạn chưa chọn được sản phẩm nào.', style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('MUA SẮM NGAY'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(CartViewModel vm) {
    final dealsVm = context.watch<DealsViewModel>();
    final bogoProductIds = <int>{};
    for (final promo in dealsVm.bogoPromotions) {
      if (promo.isActive && promo.applicableProductIds != null) {
        bogoProductIds.addAll(promo.applicableProductIds!);
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
      children: [
        ...vm.items.expand((item) {
          final isBogo = bogoProductIds.contains(item.productId);
          return [
            _buildCartItem(item, vm),
            if (isBogo) _buildBogoFreeItem(item),
          ];
        }),
        const SizedBox(height: 24),
        _buildOrderInfoSection(),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildOrderInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text('Thông tin giao hàng', style: AppTextStyles.headingSm),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceDark, width: 1.5),
          ),
          child: Column(
            children: [
              _buildTextField('Họ và tên', _nameController, Icons.person_outline),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: AppColors.surfaceDark)),
              _buildTextField('Số điện thoại', _phoneController, Icons.phone_android_outlined, keyboardType: TextInputType.phone),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: AppColors.surfaceDark)),
              _buildTextField('Địa chỉ giao hàng', _addressController, Icons.location_on_outlined),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: AppColors.surfaceDark)),
              _buildTextField('Ghi chú cho shipper', _noteController, Icons.sticky_note_2_outlined),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySm.copyWith(color: AppColors.textHint),
        prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }

  Widget _buildBottom(CartViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng thanh toán', style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              Text(formatVND(vm.total), style: AppTextStyles.labelBold.copyWith(fontSize: 18, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () async {
                if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty || _addressController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập đầy đủ thông tin giao hàng'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                _syncOrderInfo(vm);
                
                final checkoutVm = context.read<CheckoutViewModel>();
                final dealsVm = context.read<DealsViewModel>();
                
                final bogoIds = <int>{};
                for (final promo in dealsVm.bogoPromotions) {
                  if (promo.isActive && promo.applicableProductIds != null) {
                    bogoIds.addAll(promo.applicableProductIds!);
                  }
                }

                final success = await checkoutVm.checkAvailability(
                  items: vm.items,
                  bogoProductIds: bogoIds,
                  recipientName: _nameController.text,
                  phoneNumber: _phoneController.text,
                  address: _addressController.text,
                  note: _noteController.text,
                );

                if (success && mounted) {
                  context.push('/checkout');
                } else if (!success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(checkoutVm.errorMessage ?? 'Không thể kiểm tra sản phẩm.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text('TIẾN HÀNH THANH TOÁN (${vm.itemCount})', style: AppTextStyles.labelBold.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(CartViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xóa giỏ hàng?'),
        content: const Text('Tất cả sản phẩm trong giỏ hàng sẽ bị gỡ bỏ. Bạn chắc chắn chứ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              vm.clearCart();
              Navigator.pop(ctx);
            },
            child: const Text('Xóa tất cả', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItemModel item, CartViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceDark),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(item.imageUrl, width: 80, height: 80, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceDark, width: 80, height: 80, child: const Icon(Icons.image_outlined))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, style: AppTextStyles.labelBold, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(formatVND(item.price), style: AppTextStyles.priceSm.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          Row(
            children: [
              _QtyButton(icon: Icons.remove, onTap: () => vm.updateQuantity(item.productId, item.quantity - 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('${item.quantity}', style: AppTextStyles.labelBold),
              ),
              _QtyButton(icon: Icons.add, onTap: () => vm.updateQuantity(item.productId, item.quantity + 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBogoFreeItem(CartItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 24),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text('Tặng kèm 1 ${item.productName}', style: AppTextStyles.bodySm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
            child: const Text('MIỄN PHÍ', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.surfaceDark)),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _SummaryRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTextStyles.labelBold.copyWith(color: valueColor ?? AppColors.textPrimary)),
      ],
    );
  }
}
