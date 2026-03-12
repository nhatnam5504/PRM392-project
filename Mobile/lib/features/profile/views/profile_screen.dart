import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../view_models/profile_view_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile data when screen opens
    Future.microtask(() {
      context.read<ProfileViewModel>().loadProfile();
    });
  }

  Future<void> _handleLogout() async {
    final authVM = context.read<AuthViewModel>();
    await authVM.logout();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, profileVM, _) {
        final user = profileVM.user;
        final isLoading = profileVM.isLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : ListView(
                    padding:
                        const EdgeInsets.all(16),
                    children: [
                      // Profile header
                      Container(
                        padding:
                            const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(
                                  16),
                          boxShadow: const [
                            BoxShadow(
                              color:
                                  Color(0x0D000000),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor:
                                  AppColors
                                      .primaryLight,
                              child: Text(
                                (user?.name ??
                                        'U')
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: AppTextStyles
                                    .displayLarge
                                    .copyWith(
                                  color: AppColors
                                      .primary,
                                ),
                              ),
                            ),
                            const SizedBox(
                                height: 12),
                            Text(
                              user?.name ??
                                  'Chưa có tên',
                              style: AppTextStyles
                                  .headingMd,
                            ),
                            const SizedBox(
                                height: 4),
                            Text(
                              user?.email ??
                                  'Chưa có email',
                              style: AppTextStyles
                                  .bodyMd
                                  .copyWith(
                                color: AppColors
                                    .textSecondary,
                              ),
                            ),
                            const SizedBox(
                                height: 12),
                            if (user?.role !=
                                null) ...[
                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: AppColors
                                      .primaryLight,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              20),
                                ),
                                child: Text(
                                  user!.role!,
                                  style:
                                      AppTextStyles
                                          .labelMd
                                          .copyWith(
                                    color: AppColors
                                        .primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (profileVM.errorMessage !=
                          null) ...[
                        const SizedBox(height: 8),
                        Text(
                          profileVM.errorMessage!,
                          style: AppTextStyles.bodySm
                              .copyWith(
                            color: AppColors.error,
                          ),
                          textAlign:
                              TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 16),
            // Account menu
            _MenuSection(
              title: 'Tài khoản',
              items: [
                _MenuItem(
                  icon: Icons.person_outline,
                  label: 'Thông tin cá nhân',
                  onTap: () =>
                      context.push('/profile/edit'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Shopping menu
            _MenuSection(
              title: 'Mua sắm',
              items: [
                _MenuItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Đơn hàng',
                  onTap: () =>
                      context.push('/orders'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Logout button
            OutlinedButton(
              onPressed: _handleLogout,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppColors.error,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                minimumSize: const Size(
                  double.infinity,
                  52,
                ),
              ),
              child: Text(
                'Đăng xuất',
                style: AppTextStyles.buttonLg
                    .copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'v1.0.0',
                style: AppTextStyles.bodySm,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
      },
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16, 16, 16, 8,
            ),
            child: Text(
              title,
              style: AppTextStyles.labelSm
                  .copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMd,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
