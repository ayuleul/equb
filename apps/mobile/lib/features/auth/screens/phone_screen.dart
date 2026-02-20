import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../auth_controller.dart';
import '../auth_state.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  late final TextEditingController _phoneController;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      setState(() {
        _validationError = 'Phone number is required.';
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('Phone number is required.')),
      );
      return;
    }

    setState(() {
      _validationError = null;
    });

    final success = await ref
        .read(authControllerProvider.notifier)
        .requestOtp(phone);

    if (!mounted) {
      return;
    }

    final authState = ref.read(authControllerProvider);
    if (!success) {
      final message = authState.errorMessage;
      if (message != null && message.isNotEmpty) {
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
      return;
    }

    ref.read(authControllerProvider.notifier).setOtpPhone(phone);
    final encodedPhone = Uri.encodeQueryComponent(phone);
    context.go('${AppRoutePaths.otp}?phone=$encodedPhone');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          previousError != nextError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(nextError)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Login with your phone',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Enter your phone number to receive a one-time code.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _phoneController,
                label: 'Phone number',
                hint: '+251911223344',
                keyboardType: TextInputType.phone,
                onChanged: (_) {
                  if (_validationError != null) {
                    setState(() {
                      _validationError = null;
                    });
                  }
                  if (authState.hasError) {
                    ref.read(authControllerProvider.notifier).clearError();
                  }
                },
              ),
              if (_validationError != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _validationError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              if (authState.hasError) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  authState.errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Request OTP',
                isLoading: authState.isRequestingOtp,
                onPressed: authState.isRequestingOtp ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
