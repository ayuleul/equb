import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/phone_numbers.dart';
import '../auth_controller.dart';
import '../auth_state.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  late PhoneNumberValue _phoneValue;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _phoneValue = PhoneNumberValue(
      country: countryCallingCodeByIso('ET'),
      rawInput: '',
    );
  }

  Future<void> _submit() async {
    final phone = _phoneValue.normalizedPhone;
    if (phone == null) {
      setState(() => _validationError = 'Phone number is required.');
      KitToast.error(context, 'Phone number is required.');
      return;
    }
    if (phone.isEmpty) {
      const message = 'Enter a valid phone number';
      setState(() => _validationError = message);
      KitToast.error(context, message);
      return;
    }

    setState(() => _validationError = null);

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
        KitToast.error(context, message);
      }
      return;
    }

    ref.read(authControllerProvider.notifier).setOtpPhone(phone);
    final encodedPhone = Uri.encodeQueryComponent(phone);
    context.push('${AppRoutePaths.otp}?phone=$encodedPhone');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          previousError != nextError) {
        KitToast.error(context, nextError);
      }
    });

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
                  'Welcome back',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Enter your phone number to receive a one-time verification code.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                KitPhoneNumberField(
                  value: _phoneValue,
                  errorText: _validationError,
                  onChanged: (value) => _phoneValue = value,
                  onClearedError: () {
                    if (_validationError != null) {
                      setState(() => _validationError = null);
                    }
                    if (authState.hasError) {
                      ref.read(authControllerProvider.notifier).clearError();
                    }
                  },
                ),
                if (authState.hasError) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    authState.errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                KitPrimaryButton(
                  label: authState.isRequestingOtp
                      ? 'Sending code...'
                      : 'Request OTP',
                  onPressed: authState.isRequestingOtp ? null : _submit,
                  isLoading: authState.isRequestingOtp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
