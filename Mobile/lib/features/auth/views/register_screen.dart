import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../view_models/auth_view_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password =
        _passwordController.text.trim();
    final confirmPassword =
        _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng điền đầy đủ thông tin',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mật khẩu xác nhận không khớp',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authVM = context.read<AuthViewModel>();
    final success = await authVM.register(
      name: name,
      phone: phone,
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authVM.errorMessage ??
                'Đăng ký thất bại',
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
          Positioned(
            top: -100,
            left: -100,
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
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Logo section
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, const Color(0xFF22D3EE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.devices_other_rounded, color: Colors.white, size: 40),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Tạo tài khoản mới',
                    style: AppTextStyles.displayMedium.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tham gia TechGear để nhận nhiều ưu đãi hẫn dẫn',
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // Fields
                  _buildInputField(
                    label: 'Họ và tên',
                    controller: _nameController,
                    hint: 'Nguyễn Văn A',
                    icon: Icons.person_outline_rounded,
                    enabled: !authVM.isLoading,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    label: 'Số điện thoại',
                    controller: _phoneController,
                    hint: '0123 456 789',
                    icon: Icons.phone_android_rounded,
                    keyboardType: TextInputType.phone,
                    enabled: !authVM.isLoading,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    label: 'Email',
                    controller: _emailController,
                    hint: 'example@email.com',
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !authVM.isLoading,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    label: 'Mật khẩu',
                    controller: _passwordController,
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                    enabled: !authVM.isLoading,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    label: 'Xác nhận mật khẩu',
                    controller: _confirmPasswordController,
                    hint: '••••••••',
                    icon: Icons.lock_reset_rounded,
                    isPassword: true,
                    isConfirm: true,
                    enabled: !authVM.isLoading,
                  ),
                  const SizedBox(height: 24),
                  // Terms
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _agreedToTerms,
                          onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'Tôi đồng ý với ',
                            style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                            children: [
                              TextSpan(
                                text: 'Điều khoản',
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
                              ),
                              const TextSpan(text: ' & '),
                              TextSpan(
                                text: 'Chính sách',
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Register button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: _agreedToTerms ? [AppColors.primary, const Color(0xFF0891B2)] : [Colors.grey, Colors.grey.shade400],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: _agreedToTerms ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ] : [],
                      ),
                      child: ElevatedButton(
                        onPressed: (_agreedToTerms && !authVM.isLoading) ? _handleRegister : null,
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
                            : Text('Đăng ký tài khoản', style: AppTextStyles.buttonLg.copyWith(fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đã có tài khoản?',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'Đăng nhập ngay',
                          style: AppTextStyles.labelBold.copyWith(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
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
    bool isConfirm = false,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelBold.copyWith(fontSize: 14)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.surfaceDark),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && (isConfirm ? _obscureConfirm : _obscurePassword),
            enabled: enabled,
            keyboardType: keyboardType,
            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textHint.withValues(alpha: 0.5)),
              prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        (isConfirm ? _obscureConfirm : _obscurePassword) ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                      onPressed: () => setState(() {
                        if (isConfirm) {
                          _obscureConfirm = !_obscureConfirm;
                        } else {
                          _obscurePassword = !_obscurePassword;
                        }
                      }),
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
