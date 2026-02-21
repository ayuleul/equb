import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
sealed class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String phone,
    String? firstName,
    String? middleName,
    String? lastName,
    String? fullName,
    bool? profileComplete,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  bool get hasCompleteProfile {
    final explicit = profileComplete;
    if (explicit != null) {
      return explicit;
    }

    return _hasValue(firstName) && _hasValue(middleName) && _hasValue(lastName);
  }

  String get displayName {
    final directFullName = fullName?.trim();
    if (directFullName != null && directFullName.isNotEmpty) {
      return directFullName;
    }

    final parts = <String>[
      firstName?.trim() ?? '',
      middleName?.trim() ?? '',
      lastName?.trim() ?? '',
    ].where((part) => part.isNotEmpty).toList();

    if (parts.isNotEmpty) {
      return parts.join(' ');
    }

    return 'Equb member';
  }

  static bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
