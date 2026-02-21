import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/auth/auth_repository.dart';
import '../../data/models/user_model.dart';
import '../../shared/utils/api_error_mapper.dart';
import 'auth_state.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    return AuthController(ref: ref, authRepository: authRepository);
  },
);

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authControllerProvider).user;
});

class AuthController extends StateNotifier<AuthState> {
  AuthController({required Ref ref, required AuthRepository authRepository})
    : _ref = ref,
      _authRepository = authRepository,
      super(const AuthState.unknown());

  final Ref _ref;
  final AuthRepository _authRepository;
  Future<void>? _bootstrapFuture;

  Future<void> bootstrap() {
    final inFlight = _bootstrapFuture;
    if (inFlight != null) {
      return inFlight;
    }

    final task = _runBootstrap();
    _bootstrapFuture = task;
    return task;
  }

  Future<void> _runBootstrap() async {
    state = const AuthState.authenticating(operation: AuthOperation.bootstrap);
    _ref.read(sessionExpiredProvider.notifier).state = false;

    try {
      final user = await _authRepository.restoreSession();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (error) {
      state = AuthState.error(message: mapApiErrorToMessage(error));
      state = const AuthState.unauthenticated();
    } finally {
      _bootstrapFuture = null;
    }
  }

  void setOtpPhone(String phone) {
    final normalizedPhone = phone.trim();
    if (normalizedPhone.isEmpty) {
      return;
    }

    state = state.copyWith(
      otpPhone: normalizedPhone,
      clearError: true,
      status: state.isAuthenticated
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated,
      operation: AuthOperation.none,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> setAuthenticatedUser(UserModel user) async {
    await _authRepository.cacheUser(user);
    _ref.read(sessionExpiredProvider.notifier).state = false;
    state = AuthState.authenticated(user);
  }

  Future<bool> requestOtp(String phone) async {
    final normalizedPhone = phone.trim();
    if (normalizedPhone.isEmpty) {
      state = AuthState.error(
        message: 'Phone number is required.',
        otpPhone: state.otpPhone,
        user: state.user,
      );
      return false;
    }

    state = AuthState.authenticating(
      operation: AuthOperation.requestOtp,
      otpPhone: normalizedPhone,
      user: state.user,
    );

    try {
      await _authRepository.requestOtp(normalizedPhone);
      state = AuthState.unauthenticated(otpPhone: normalizedPhone);
      return true;
    } catch (error) {
      state = AuthState.error(
        message: mapApiErrorToMessage(error),
        otpPhone: normalizedPhone,
        user: state.user,
      );
      return false;
    }
  }

  Future<bool> verifyOtp({required String phone, required String code}) async {
    final normalizedPhone = phone.trim();
    final normalizedCode = code.trim();

    if (normalizedPhone.isEmpty) {
      state = AuthState.error(
        message: 'Phone number is missing. Request OTP again.',
        otpPhone: state.otpPhone,
        user: state.user,
      );
      return false;
    }

    if (normalizedCode.isEmpty) {
      state = AuthState.error(
        message: 'OTP code is required.',
        otpPhone: normalizedPhone,
        user: state.user,
      );
      return false;
    }

    state = AuthState.authenticating(
      operation: AuthOperation.verifyOtp,
      otpPhone: normalizedPhone,
      user: state.user,
    );

    try {
      final user = await _authRepository.verifyOtp(
        phone: normalizedPhone,
        code: normalizedCode,
      );

      _ref.read(sessionExpiredProvider.notifier).state = false;
      state = AuthState.authenticated(user);
      return true;
    } catch (error) {
      state = AuthState.error(
        message: mapApiErrorToMessage(error),
        otpPhone: normalizedPhone,
        user: state.user,
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = AuthState.authenticating(
      operation: AuthOperation.logout,
      user: state.user,
      otpPhone: state.otpPhone,
    );

    try {
      await _authRepository.logout();
    } catch (error) {
      state = AuthState.error(
        message: mapApiErrorToMessage(error),
        otpPhone: state.otpPhone,
      );
    } finally {
      _ref.read(sessionExpiredProvider.notifier).state = false;
      state = const AuthState.unauthenticated();
    }
  }
}
