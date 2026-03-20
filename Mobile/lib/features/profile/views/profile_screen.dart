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
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text('Tài khoản', style: AppTextStyles.headingMd),
            centerTitle: true,
          ),
          body: SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                    children: [
                      // Profile header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.surfaceDark, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                                  ),
                                  child: CircleAvatar(
                                    radius: 45,
                                    backgroundColor: AppColors.primary.withOpacity(0.1),
                                    child: Text(
                                      (user?.name ?? 'U').substring(0, 1).toUpperCase(),
                                      style: AppTextStyles.displayLarge.copyWith(color: AppColors.primary, fontSize: 32),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                  child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(user?.name ?? 'Người dùng', style: AppTextStyles.headingMd),
                            const SizedBox(height: 4),
                            Text(user?.email ?? 'Chưa cập nhật email', style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
                            if (user?.role != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                child: Text(user!.role!.toUpperCase(), style: AppTextStyles.labelBold.copyWith(color: AppColors.primary, fontSize: 10, letterSpacing: 1)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      if (profileVM.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(profileVM.errorMessage!, style: AppTextStyles.bodySm.copyWith(color: AppColors.error), textAlign: TextAlign.center),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Menus
                      _MenuSection(
                        title: 'TÀI KHOẢN',
                        items: [
                          _MenuItem(
                            icon: Icons.person_outline_rounded,
                            label: 'Thông tin cá nhân',
                            onTap: () => context.push('/profile/edit'),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _MenuSection(
                        title: 'MUA SẮM',
                        items: [
                          _MenuItem(
                            icon: Icons.inventory_2_outlined,
                            label: 'Lịch sử đơn hàng',
                            onTap: () => context.push('/orders'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      
                      // Logout
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _handleLogout,
                          icon: const Icon(Icons.logout_rounded, size: 20),
                          label: const Text('ĐĂNG XUẤT'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      Center(child: Text('Phiên bản 1.0.0 Premium', style: AppTextStyles.caption.copyWith(color: AppColors.textHint))),
                      const SizedBox(height: 20),
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

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title, style: AppTextStyles.labelBold.copyWith(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceDark, width: 1.5),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              return Column(
                children: [
                  items[index],
                  if (index < items.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(height: 1, color: AppColors.surfaceDark),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: AppTextStyles.labelBold.copyWith(color: AppColors.textPrimary, fontSize: 14))),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textHint, size: 14),
          ],
        ),
      ),
    );
  }
}
