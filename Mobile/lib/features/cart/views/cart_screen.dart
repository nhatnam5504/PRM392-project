import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/format_price.dart';
import '../../../data/models/cart_item_model.dart';
import '../../deals/view_models/deals_view_model.dart';
import '../view_models/cart_view_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() =>
      _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) return;
        context.read<CartViewModel>().loadCart();
        final dealsVm =
            context.read<DealsViewModel>();
        if (dealsVm.promotions.isEmpty) {
          dealsVm.loadDeals();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Giỏ hàng của bạn',
            ),
            actions: [
              if (!vm.isEmpty)
                TextButton(
                  onPressed: () =>
                      _showClearDialog(vm),
                  child: Text(
                    'Xóa hết',
                    style: AppTextStyles.labelBold
                        .copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          body: vm.isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : vm.isEmpty
                  ? _buildEmptyCart()
                  : _buildCartContent(vm),
          bottomNavigationBar:
              vm.isEmpty ? null : _buildBottom(vm),
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          const Text(
            'Giỏ hàng trống',
            style: AppTextStyles.headingSm,
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm sản phẩm vào giỏ hàng',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/shop'),
            child: const Text('Mua sắm ngay'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(CartViewModel vm) {
    final dealsVm =
        context.watch<DealsViewModel>();
    final bogoProductIds = <int>{};
    for (final promo in dealsVm.bogoPromotions) {
      if (promo.isActive &&
          promo.applicableProductIds != null) {
        bogoProductIds.addAll(
          promo.applicableProductIds!,
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...vm.items.expand(
          (item) {
            final isBogo = bogoProductIds
                .contains(item.productId);
            return [
              _buildCartItem(item, vm),
              if (isBogo)
                _buildBogoFreeItem(item),
            ];
          },
        ),
        const SizedBox(height: 12),
        // Summary
        _buildSummary(vm),
      ],
    );
  }

  Widget _buildCartItem(
    CartItemModel item,
    CartViewModel vm,
  ) {
    return Dismissible(
      key: ValueKey(item.productId),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius:
              BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) =>
          vm.removeItem(item.productId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(8),
              child: item.imageUrl.isNotEmpty
                  ? Image.network(
                      item.imageUrl,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) =>
                              _buildImgPlaceholder(),
                    )
                  : _buildImgPlaceholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style:
                        AppTextStyles.labelBold,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.brandName,
                    style: AppTextStyles.bodySm
                        .copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      Text(
                        formatVND(item.price),
                        style:
                            AppTextStyles.priceSm,
                      ),
                      _buildQuantitySelector(
                        item,
                        vm,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImgPlaceholder() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.border,
      ),
    );
  }

  Widget _buildBogoFreeItem(CartItemModel item) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
        left: 24,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryLight
            .withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary
              .withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(6),
            child: item.imageUrl.isNotEmpty
                ? Image.network(
                    item.imageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) =>
                            _buildSmallPlaceholder(),
                  )
                : _buildSmallPlaceholder(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius:
                            BorderRadius.circular(
                          3,
                        ),
                      ),
                      child: Text(
                        'TẶNG KÈM',
                        style: AppTextStyles
                            .labelSm
                            .copyWith(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius:
                            BorderRadius.circular(
                          3,
                        ),
                      ),
                      child: Text(
                        'BOGO',
                        style: AppTextStyles
                            .labelSm
                            .copyWith(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.productName,
                  style: AppTextStyles.bodySm,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '0đ',
                      style: AppTextStyles
                          .labelBold
                          .copyWith(
                        color: AppColors.success,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formatVND(item.price),
                      style: AppTextStyles
                          .priceStrike
                          .copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            'x${item.quantity}',
            style: AppTextStyles.bodySm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius:
            BorderRadius.circular(6),
      ),
      child: const Icon(
        Icons.card_giftcard,
        color: AppColors.primary,
        size: 20,
      ),
    );
  }

  Widget _buildQuantitySelector(
    CartItemModel item,
    CartViewModel vm,
  ) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (item.quantity > 1) {
                vm.updateQuantity(
                  item.productId,
                  item.quantity - 1,
                );
              } else {
                vm.removeItem(item.productId);
              }
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.remove,
                size: 14,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            child: Text(
              item.quantity
                  .toString()
                  .padLeft(2, '0'),
              style: AppTextStyles.labelMd
                  .copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (!item.isMaxQty) {
                vm.updateQuantity(
                  item.productId,
                  item.quantity + 1,
                );
              }
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: item.isMaxQty
                    ? AppColors.textHint
                    : AppColors.primary,
                borderRadius:
                    BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.add,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherSection(CartViewModel vm) {
    final controller = TextEditingController();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'MÃ GIẢM GIÁ',
            style: AppTextStyles.labelSm
                .copyWith(letterSpacing: 0.8),
          ),
          const SizedBox(height: 12),
          if (vm.appliedVoucher != null)
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mã ${vm.appliedVoucher!.code} '
                  'đã áp dụng',
                  style: AppTextStyles.labelBold
                      .copyWith(
                    color: AppColors.success,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: vm.removeVoucher,
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: TextField(
                      controller: controller,
                      decoration:
                          InputDecoration(
                        hintText:
                            'Nhập mã giảm giá',
                        hintStyle: AppTextStyles
                            .bodyMd
                            .copyWith(
                          color:
                              AppColors.textHint,
                        ),
                        prefixIcon: const Icon(
                          Icons
                              .confirmation_number_outlined,
                          size: 16,
                          color:
                              AppColors.textHint,
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(
                          minWidth: 36,
                        ),
                        filled: true,
                        fillColor: AppColors
                            .inputBackground,
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(8),
                          borderSide:
                              const BorderSide(
                            color:
                                AppColors.divider,
                          ),
                        ),
                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(8),
                          borderSide:
                              const BorderSide(
                            color:
                                AppColors.divider,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (controller
                        .text.isNotEmpty) {
                      vm.applyVoucher(
                        controller.text,
                      );
                    }
                  },
                  child: Container(
                    height: 36,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius:
                          BorderRadius.circular(
                        8,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Áp dụng',
                        style: AppTextStyles
                            .labelBold
                            .copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (vm.errorMessage != null &&
              vm.appliedVoucher == null)
            Padding(
              padding:
                  const EdgeInsets.only(top: 8),
              child: Text(
                vm.errorMessage!,
                style: AppTextStyles.bodySm
                    .copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummary(CartViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(
            'Tạm tính',
            formatVND(vm.subtotal),
          ),
          if (vm.discount > 0) ...[
            const SizedBox(height: 12),
            _SummaryRow(
              'Giảm giá',
              '-${formatVND(vm.discount)}',
              valueColor: AppColors.success,
            ),
          ],
          const SizedBox(height: 12),
          const Divider(
            color: AppColors.divider,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng',
                style: AppTextStyles.headingSm,
              ),
              Text(
                formatVND(vm.total),
                style: AppTextStyles.priceLg,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottom(CartViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.borderLight,
          ),
        ),
      ),
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: () =>
              context.push('/checkout'),
          child: Text(
            'Tiến hành thanh toán '
            '(${vm.itemCount})',
          ),
        ),
      ),
    );
  }

  void _showClearDialog(CartViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa giỏ hàng'),
        content: const Text(
          'Bạn có chắc muốn xóa tất cả '
          'sản phẩm khỏi giỏ hàng?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              vm.clearCart();
              Navigator.pop(ctx);
            },
            child: Text(
              'Xóa hết',
              style: TextStyle(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow(
    this.label,
    this.value, {
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style:
              AppTextStyles.labelBold.copyWith(
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
