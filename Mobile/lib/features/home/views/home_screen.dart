import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../view_models/home_view_model.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_grid.dart';
import '../widgets/section_header.dart';
import '../widgets/featured_products_row.dart';
import '../widgets/newsletter_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(vm.errorMessage!),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => vm.loadHomeData(),
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => vm.loadHomeData(),
                        child: CustomScrollView(
                          slivers: [
                            const SliverToBoxAdapter(
                              child: HomeAppBar(),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 16),
                            ),
                            if (vm.banners.isNotEmpty)
                              SliverToBoxAdapter(
                                child: BannerCarousel(
                                  banners: vm.banners,
                                ),
                              ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 24),
                            ),
                            if (vm.categories.isNotEmpty) ...[
                              const SliverToBoxAdapter(
                                child: SectionHeader(
                                  title: 'DANH MỤC NỔI BẬT',
                                ),
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 16),
                              ),
                              SliverToBoxAdapter(
                                child: CategoryGrid(
                                  categories: vm.categories,
                                ),
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 24),
                              ),
                            ],
                            if (vm.featuredProducts.isNotEmpty) ...[
                              SliverToBoxAdapter(
                                child: SectionHeader(
                                  title: 'SẢN PHẨM NỔI BẬT',
                                  onViewAll: () => context.push('/products'),
                                ),
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 16),
                              ),
                              SliverToBoxAdapter(
                                child: FeaturedProductsRow(
                                  products: vm.featuredProducts,
                                ),
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 24),
                              ),
                            ],
                            if (vm.flashSaleProducts.isNotEmpty) ...[
                              SliverToBoxAdapter(
                                child: SectionHeader(
                                  title: 'FLASH SALE',
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '⚡ 23:59:59',
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 16),
                              ),
                              SliverToBoxAdapter(
                                child: FeaturedProductsRow(
                                  products: vm.flashSaleProducts,
                                ),
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 24),
                              ),
                            ],
                            const SliverToBoxAdapter(
                              child: NewsletterSection(),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 24),
                            ),
                          ],
                        ),
                      ),
          ),
        );
      },
    );
  }
}
