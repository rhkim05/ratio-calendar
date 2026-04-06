import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/core/router/app_router.dart';
import 'package:ratio_calendar/core/theme/app_colors.dart';
import 'package:ratio_calendar/core/theme/app_typography.dart';
import 'package:ratio_calendar/features/auth/presentation/providers/auth_providers.dart';

/// 로그인 화면
///
/// - 이메일 + 비밀번호
/// - Google 소셜 로그인
/// - 회원가입 링크
/// - DM Sans, 미니멀 스타일
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authProvider.notifier).signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  Future<void> _handleGoogleSignIn() async {
    await ref.read(authProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;

    // 로그인 성공 시 뒤로가기
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next is AuthAuthenticated) {
        context.pop();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── 헤더 ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.xs,
                vertical: AppSizes.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // ── 콘텐츠 ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSizes.xxl),

                      // 타이틀
                      Text(
                        'SIGN IN',
                        style: AppTypography.headline.copyWith(
                          fontSize: 28,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        'Sync your calendar across devices',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: AppSizes.xxl + AppSizes.md),

                      // 에러 메시지
                      if (authState is AuthError) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSizes.sm),
                          decoration: BoxDecoration(
                            color: AppColors.work.withValues(alpha: 0.08),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMd),
                          ),
                          child: Text(
                            authState.message,
                            style: AppTypography.body.copyWith(
                              color: AppColors.work,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                      ],

                      // 이메일 필드
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!v.contains('@')) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.md),

                      // 비밀번호 필드
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        obscureText: _obscurePassword,
                        suffix: GestureDetector(
                          onTap: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppSizes.lg + AppSizes.sm),

                      // Sign In 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleEmailSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textPrimary,
                            foregroundColor: AppColors.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMd,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.background,
                                  ),
                                )
                              : Text(
                                  'Sign In',
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.background,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.lg),

                      // 구분선
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.divider)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.md,
                            ),
                            child: Text(
                              'or',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.divider)),
                        ],
                      ),

                      const SizedBox(height: AppSizes.lg),

                      // Google 로그인 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: isLoading ? null : _handleGoogleSignIn,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: BorderSide(
                              color: AppColors.outlineVariant.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMd,
                              ),
                            ),
                          ),
                          icon: const Text(
                            'G',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          label: Text(
                            'Continue with Google',
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.xxl),

                      // 회원가입 링크
                      Center(
                        child: GestureDetector(
                          onTap: () => context.push(AppRoutes.signup),
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account?  ",
                              style: AppTypography.body.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign Up',
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.personal,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.xxl),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: AppTypography.body,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.body.copyWith(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        suffixIcon: suffix != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffix,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 20,
          minHeight: 20,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.textPrimary),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.work),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.work),
        ),
        errorStyle: AppTypography.caption.copyWith(
          color: AppColors.work,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.only(bottom: 8),
      ),
    );
  }
}
