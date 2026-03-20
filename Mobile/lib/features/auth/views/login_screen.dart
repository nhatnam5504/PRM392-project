import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../view_models/auth_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng nhập email và mật khẩu',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authVM = context.read<AuthViewModel>();
    final success = await authVM.login(
      identifier,
      password,
    );

    if (!mounted) return;

    if (success) {
      final role = authVM.user?.role ?? '';
      if (role == 'SUPER ADMIN' || role == 'ADMIN' || role == 'STAFF') {
        context.go('/admin/products');
      } else {
        context.go('/');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authVM.errorMessage ?? 'Đăng nhập thất bại',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background decorative element
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Logo section
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, const Color(0xFF22D3EE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.devices_other_rounded, color: Colors.white, size: 48),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tech',
                        style: AppTextStyles.displayMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 32,
                        ),
                      ),
                      Text(
                        'Gear',
                        style: AppTextStyles.displayMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PHỤ KIỆN CÔNG NGHỆ CAO CẤP',
                    style: AppTextStyles.labelBold.copyWith(
                      color: AppColors.textHint,
                      letterSpacing: 2,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 56),
                  // Welcome text
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chào mừng trở lại!',
                          style: AppTextStyles.displayMedium.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Đăng nhập để tiếp tục trải nghiệm mua sắm',
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Input fields
                  _buildInputField(
                    label: 'Email hoặc Số điện thoại',
                    controller: _identifierController,
                    hint: 'example@email.com',
                    icon: Icons.alternate_email_rounded,
                    enabled: !authVM.isLoading,
                  ),
                  const SizedBox(height: 24),
                  _buildInputField(
                    label: 'Mật khẩu',
                    controller: _passwordController,
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                    enabled: !authVM.isLoading,
                    trailing: GestureDetector(
                      onTap: () => context.push('/forgot-password'),
                      child: Text(
                        'Quên?',
                        style: AppTextStyles.labelBold.copyWith(color: AppColors.primary, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [AppColors.primary, const Color(0xFF0891B2)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: authVM.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: authVM.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Đăng nhập', style: AppTextStyles.buttonLg.copyWith(fontWeight: FontWeight.w900)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chưa có tài khoản?',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => context.push('/register'),
                        child: Text(
                          'Đăng ký ngay',
                          style: AppTextStyles.labelBold.copyWith(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Skip link
                  TextButton(
                    onPressed: () => context.go('/'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textHint,
                    ),
                    child: const Text('Tiếp tục với tư cách khách'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool enabled = true,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.labelBold.copyWith(fontSize: 14)),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.surfaceDark),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && _obscurePassword,
            enabled: enabled,
            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textHint.withValues(alpha: 0.5)),
              prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}
