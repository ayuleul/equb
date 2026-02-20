import '../../data/models/user_model.dart';

enum AuthStatus {
  unknown,
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

enum AuthOperation { none, bootstrap, requestOtp, verifyOtp, logout }

class AuthState {
  const AuthState({
    required this.status,
    required this.operation,
    this.user,
    this.otpPhone,
    this.errorMessage,
  });

  const AuthState.unknown()
    : this(status: AuthStatus.unknown, operation: AuthOperation.none);

  const AuthState.unauthenticated({
    String? otpPhone,
    String? errorMessage,
    UserModel? user,
  }) : this(
         status: AuthStatus.unauthenticated,
         operation: AuthOperation.none,
         otpPhone: otpPhone,
         errorMessage: errorMessage,
         user: user,
       );

  const AuthState.authenticating({
    required AuthOperation operation,
    UserModel? user,
    String? otpPhone,
  }) : this(
         status: AuthStatus.authenticating,
         operation: operation,
         user: user,
         otpPhone: otpPhone,
       );

  const AuthState.authenticated(UserModel user)
    : this(
        status: AuthStatus.authenticated,
        operation: AuthOperation.none,
        user: user,
      );

  const AuthState.error({
    required String message,
    UserModel? user,
    String? otpPhone,
  }) : this(
         status: AuthStatus.error,
         operation: AuthOperation.none,
         user: user,
         otpPhone: otpPhone,
         errorMessage: message,
       );

  final AuthStatus status;
  final AuthOperation operation;
  final UserModel? user;
  final String? otpPhone;
  final String? errorMessage;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  bool get isRequestingOtp => operation == AuthOperation.requestOtp;

  bool get isVerifyingOtp => operation == AuthOperation.verifyOtp;

  bool get isLoggingOut => operation == AuthOperation.logout;

  bool get isBootstrapping =>
      status == AuthStatus.unknown || operation == AuthOperation.bootstrap;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  AuthState copyWith({
    AuthStatus? status,
    AuthOperation? operation,
    UserModel? user,
    bool clearUser = false,
    String? otpPhone,
    bool clearOtpPhone = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      operation: operation ?? this.operation,
      user: clearUser ? null : (user ?? this.user),
      otpPhone: clearOtpPhone ? null : (otpPhone ?? this.otpPhone),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
