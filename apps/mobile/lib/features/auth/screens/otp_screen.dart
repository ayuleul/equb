import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../auth_controller.dart';
import '../auth_state.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, this.phone});

  final String? phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const int _resendCooldownSeconds = 45;

  late final TextEditingController _otpController;
  Timer? _cooldownTimer;
  int _remainingSeconds = _resendCooldownSeconds;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();

    final initialPhone = widget.phone?.trim();
    if (initialPhone != null && initialPhone.isNotEmpty) {
      Future<void>.microtask(() {
        if (!mounted) {
          return;
        }
        ref.read(authControllerProvider.notifier).setOtpPhone(initialPhone);
      });
    }

    _startCooldown();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() {
      _remainingSeconds = _resendCooldownSeconds;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
        });
        return;
      }

      setState(() {
        _remainingSeconds -= 1;
      });
    });
  }

  Future<void> _verify(String phone) async {
    final messenger = ScaffoldMessenger.of(context);
    final code = _otpController.text.trim();

    if (code.length != 6) {
      setState(() {
        _validationError = 'Enter the 6-digit OTP code.';
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit OTP code.')),
      );
      return;
    }

    setState(() {
      _validationError = null;
    });

    final success = await ref
        .read(authControllerProvider.notifier)
        .verifyOtp(phone: phone, code: code);

    if (!mounted) {
      return;
    }

    if (success) {
      context.go(AppRoutePaths.home);
      return;
    }

    final message = ref.read(authControllerProvider).errorMessage;
    if (message != null && message.isNotEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _resend(String phone) async {
    final messenger = ScaffoldMessenger.of(context);

    final success = await ref
        .read(authControllerProvider.notifier)
        .requestOtp(phone);

    if (!mounted) {
      return;
    }

    if (!success) {
      final message = ref.read(authControllerProvider).errorMessage;
      if (message != null && message.isNotEmpty) {
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
      return;
    }

    messenger.showSnackBar(
      const SnackBar(content: Text('A new OTP code has been sent.')),
    );
    _startCooldown();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final routePhone = widget.phone?.trim();
    final phone = (routePhone != null && routePhone.isNotEmpty)
        ? routePhone
        : authState.otpPhone;

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

    if (phone == null || phone.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('OTP Verification')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone number is missing. Request a new OTP to continue.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Back to Login',
                  onPressed: () => context.go(AppRoutePaths.login),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final canResend = _remainingSeconds == 0 && !authState.isRequestingOtp;

    return Scaffold(
      appBar: AppBar(title: const Text('OTP Verification')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter verification code',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('Code sent to $phone', style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _otpController,
                label: 'OTP code',
                hint: '123456',
                keyboardType: TextInputType.number,
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
                label: 'Verify OTP',
                isLoading: authState.isVerifyingOtp,
                onPressed: authState.isVerifyingOtp
                    ? null
                    : () => _verify(phone),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: canResend ? () => _resend(phone) : null,
                child: Text(
                  canResend
                      ? 'Resend OTP'
                      : 'Resend OTP in ${_remainingSeconds}s',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
