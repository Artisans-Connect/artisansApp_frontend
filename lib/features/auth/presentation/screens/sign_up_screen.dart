import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/gradient_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const String routeName = '/auth/sign-up';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _agreed = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || !_agreed) return;
    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sign-up is stubbed for this UI phase.')),
    );
    Navigator.pushNamed(context, '/auth/role-selection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: AppColors.outline.withOpacity(0.3)),
                          ),
                          child: const Icon(Icons.brush_outlined,
                              color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text('Join Artisans',
                            style: AppTextStyles.displayMd
                                .copyWith(fontSize: 66 * 0.78)),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Create your account to connect with the best\nlocal talent.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLg,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Full Name',
                          style: AppTextStyles.bodyLg.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      AppInput(
                        controller: _nameController,
                        hint: 'John Doe',
                        prefixIcon: Icons.person_outline,
                        validator: (String? v) =>
                            (v == null || v.trim().length < 3)
                                ? 'Enter your full name.'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      Text('Email Address',
                          style: AppTextStyles.bodyLg.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      AppInput(
                        controller: _emailController,
                        hint: 'name@company.com',
                        prefixIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: (String? v) =>
                            (v == null || !v.contains('@'))
                                ? 'Enter a valid email.'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      Text('Phone Number',
                          style: AppTextStyles.bodyLg.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      AppInput(
                        controller: _phoneController,
                        hint: '+1 (555) 000-0000',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (String? v) {
                          final String value = (v ?? '').trim();
                          if (value.isEmpty) return null;
                          if (value.length < 10)
                            return 'Enter a valid phone number.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Text('Password',
                          style: AppTextStyles.bodyLg.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      AppInput(
                        controller: _passwordController,
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        validator: (String? v) => (v == null || v.length < 6)
                            ? 'Enter at least 6 characters.'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Checkbox(
                            value: _agreed,
                            onChanged: (bool? value) =>
                                setState(() => _agreed = value ?? false),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 11),
                              child: RichText(
                                text: TextSpan(
                                  style: AppTextStyles.bodyLg,
                                  children: const <TextSpan>[
                                    TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700)),
                                    TextSpan(text: ' and '),
                                    TextSpan(
                                        text: 'Privacy Policy.',
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GradientButton(
                        label: 'Sign Up',
                        trailingIcon: Icons.arrow_forward,
                        isLoading: _isSubmitting,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/auth/sign-in'),
                          child: const Text('Already have an account? Sign In'),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                                width: 60,
                                height: 2,
                                color: AppColors.outline.withOpacity(0.5)),
                            const SizedBox(width: 16),
                            const CircleAvatar(
                                radius: 4, backgroundColor: AppColors.primary),
                            const SizedBox(width: 8),
                            CircleAvatar(
                                radius: 4,
                                backgroundColor:
                                    AppColors.primary.withOpacity(0.35)),
                            const SizedBox(width: 8),
                            CircleAvatar(
                                radius: 4,
                                backgroundColor:
                                    AppColors.secondary.withOpacity(0.3)),
                            const SizedBox(width: 16),
                            Container(
                                width: 60,
                                height: 2,
                                color: AppColors.outline.withOpacity(0.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
