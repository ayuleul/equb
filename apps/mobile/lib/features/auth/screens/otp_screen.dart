import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/kit/kit.dart';
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
  late final FocusNode _otpFocusNode;
  Timer? _cooldownTimer;
  int _remainingSeconds = _resendCooldownSeconds;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _otpFocusNode = FocusNode();

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
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _remainingSeconds = _resendCooldownSeconds);

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
  }

  Future<void> _verify(String phone) async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      setState(() => _validationError = 'Enter the 6-digit OTP code.');
      KitToast.error(context, 'Enter the 6-digit OTP code.');
      return;
    }

    setState(() => _validationError = null);

    final success = await ref
        .read(authControllerProvider.notifier)
        .verifyOtp(phone: phone, code: code);

    if (!mounted) {
      return;
    }

    if (success) {
      return;
    }

    final message = ref.read(authControllerProvider).errorMessage;
    if (message != null && message.isNotEmpty) {
      KitToast.error(context, message);
    }
  }

  Future<void> _resend(String phone) async {
    final success = await ref
        .read(authControllerProvider.notifier)
        .requestOtp(phone);
    if (!mounted) {
      return;
    }

    if (!success) {
      final message = ref.read(authControllerProvider).errorMessage;
      if (message != null && message.isNotEmpty) {
        KitToast.error(context, message);
      }
      return;
    }

    KitToast.success(context, 'A new OTP code has been sent.');
    _startCooldown();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
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
        KitToast.error(context, nextError);
      }
    });

    if (phone == null || phone.isEmpty) {
      return KitScaffold(
        child: KitEmptyState(
          icon: Icons.sms_failed_outlined,
          title: 'Phone number missing',
          message: 'Request a new OTP to continue.',
          ctaLabel: 'Back to login',
          onCtaPressed: () => context.go(AppRoutePaths.login),
        ),
      );
    }

    final canResend = _remainingSeconds == 0 && !authState.isRequestingOtp;
    final otpValue = _otpController.text.trim();

    return KitScaffold(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: KitCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter verification code',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Code sent to $phone',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                GestureDetector(
                  onTap: () => _otpFocusNode.requestFocus(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List<Widget>.generate(
                      6,
                      (index) => _OtpDigitBox(
                        value: index < otpValue.length ? otpValue[index] : '',
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 0,
                  width: 0,
                  child: TextField(
                    controller: _otpController,
                    focusNode: _otpFocusNode,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    autofocus: true,
                    onChanged: (_) {
                      setState(() => _validationError = null);
                    },
                  ),
                ),
                if (_validationError != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _validationError!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                KitPrimaryButton(
                  label: authState.isVerifyingOtp
                      ? 'Verifying...'
                      : 'Verify OTP',
                  onPressed: authState.isVerifyingOtp
                      ? null
                      : () => _verify(phone),
                  isLoading: authState.isVerifyingOtp,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    KitTertiaryButton(
                      label: 'Resend OTP',
                      onPressed: canResend ? () => _resend(phone) : null,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        canResend
                            ? 'You can request a new code now.'
                            : 'Retry in ${_remainingSeconds}s',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpDigitBox extends StatelessWidget {
  const _OtpDigitBox({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 44,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.inputRounded,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(value, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
