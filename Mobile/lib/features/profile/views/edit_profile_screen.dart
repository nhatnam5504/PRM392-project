import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../view_models/profile_view_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final user =
          context.read<ProfileViewModel>().user;
      if (user != null) {
        _nameController.text = user.name;
        _emailController.text = user.email;
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Họ tên và email không được để trống',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final profileVM =
        context.read<ProfileViewModel>();
    final success = await profileVM.updateProfile(
      name: name,
      email: email,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Cập nhật hồ sơ thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            profileVM.errorMessage ??
                'Cập nhật thất bại',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileVM =
        context.watch<ProfileViewModel>();
    final user = profileVM.user;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Chỉnh sửa hồ sơ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor:
                      AppColors.primaryLight,
                  child: Text(
                    (user?.name ?? 'U')
                        .substring(0, 1)
                        .toUpperCase(),
                    style: AppTextStyles
                        .displayLarge
                        .copyWith(
                      color: AppColors.primary,
                      fontSize: 40,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildField(
              'Họ và tên',
              _nameController,
              enabled: !profileVM.isLoading,
            ),
            const SizedBox(height: 16),
            _buildField(
              'Email',
              _emailController,
              enabled: !profileVM.isLoading,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: profileVM.isLoading
                    ? null
                    : _handleSave,
                child: profileVM.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                            CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Lưu thay đổi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelBold,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: const InputDecoration(),
        ),
      ],
    );
  }
}
