import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_routes.dart';
import '../widgets/custom_text_field.dart';

/// Màn hình đăng nhập
/// Bao gồm: logo, form đăng nhập (email/SDT + mật khẩu),
/// nút đăng nhập, đăng nhập bằng mạng xã hội, và link đăng ký
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller cho ô nhập email/số điện thoại
  final TextEditingController _emailController = TextEditingController();
  // Controller cho ô nhập mật khẩu
  final TextEditingController _passwordController = TextEditingController();
  // Trạng thái hiển thị/ẩn mật khẩu
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Xử lý khi nhấn nút đăng nhập
  void _handleLogin() {
    // Tạm thời chuyển thẳng đến trang chủ (chưa có API xác thực)
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Logo và tên thương hiệu
              _buildLogo(),

              const SizedBox(height: AppSpacing.xl),

              // Lời chào
              _buildWelcomeText(),

              const SizedBox(height: AppSpacing.lg),

              // Form đăng nhập
              _buildLoginForm(),

              const SizedBox(height: AppSpacing.lg),

              // Nút đăng nhập
              _buildLoginButton(),

              const SizedBox(height: AppSpacing.lg),

              // Phần đăng nhập bằng mạng xã hội
              _buildSocialLogin(),

              const SizedBox(height: AppSpacing.lg),

              // Link đăng ký tài khoản mới
              _buildRegisterLink(),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  /// Xây dựng phần logo TechGear
  Widget _buildLogo() {
    return Column(
      children: [
        // Icon logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const Icon(Icons.devices, color: AppColors.white, size: 40),
        ),
        const SizedBox(height: AppSpacing.md),
        // Tên thương hiệu
        const Text(
          'TechGear',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        // Slogan
        Text('Phụ kiện công nghệ chính hãng', style: AppTextStyles.subtitle),
      ],
    );
  }

  /// Xây dựng phần lời chào
  Widget _buildWelcomeText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chào mừng trở lại!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Xây dựng form đăng nhập (email + mật khẩu)
  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nhãn Email/Số điện thoại
        Text(
          'Số điện thoại hoặc Email',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Ô nhập email/số điện thoại
        CustomTextField(
          hintText: 'Nhập email hoặc số điện thoại',
          prefixIcon: Icons.person_outline,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: AppSpacing.md),

        // Nhãn Mật khẩu + link Quên mật khẩu
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mật khẩu',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
            ),
            GestureDetector(
              onTap: () {
                // TODO: Điều hướng đến màn hình quên mật khẩu
              },
              child: Text(
                'Quên mật khẩu?',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        // Ô nhập mật khẩu
        CustomTextField(
          hintText: 'Nhập mật khẩu',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscurePassword,
          controller: _passwordController,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textHint,
              size: 22,
            ),
            onPressed: () {
              // Chuyển đổi ẩn/hiện mật khẩu
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
      ],
    );
  }

  /// Xây dựng nút đăng nhập
  Widget _buildLoginButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: 2,
        ),
        child: const Text('Đăng nhập', style: AppTextStyles.button),
      ),
    );
  }

  /// Xây dựng phần đăng nhập bằng mạng xã hội
  Widget _buildSocialLogin() {
    return Column(
      children: [
        // Dòng phân cách "Hoặc đăng nhập với"
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text('Hoặc đăng nhập với', style: AppTextStyles.caption),
            ),
            const Expanded(child: Divider(color: AppColors.border)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Các nút đăng nhập bằng MXH
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nút Google
            _buildSocialButton(
              icon: Icons.g_mobiledata,
              color: Colors.red,
              onTap: () {
                // TODO: Đăng nhập bằng Google
              },
            ),
            const SizedBox(width: AppSpacing.md),
            // Nút Facebook
            _buildSocialButton(
              icon: Icons.facebook,
              color: const Color(0xFF1877F2),
              onTap: () {
                // TODO: Đăng nhập bằng Facebook
              },
            ),
            const SizedBox(width: AppSpacing.md),
            // Nút Apple
            _buildSocialButton(
              icon: Icons.apple,
              color: Colors.black,
              onTap: () {
                // TODO: Đăng nhập bằng Apple
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Xây dựng một nút đăng nhập mạng xã hội
  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  /// Xây dựng link đăng ký tài khoản
  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Chưa có tài khoản? ', style: AppTextStyles.body),
        GestureDetector(
          onTap: () {
            // TODO: Điều hướng đến màn hình đăng ký
          },
          child: Text(
            'Đăng ký ngay',
            style: AppTextStyles.body.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
