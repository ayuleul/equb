class CycleBidUserModel {
  const CycleBidUserModel({required this.id, this.phone, this.fullName});

  final String id;
  final String? phone;
  final String? fullName;

  factory CycleBidUserModel.fromJson(Map<String, dynamic> json) {
    return CycleBidUserModel(
      id: (json['id'] as String?) ?? '',
      phone: json['phone'] as String?,
      fullName: json['fullName'] as String?,
    );
  }
}

class CycleBidModel {
  const CycleBidModel({
    required this.id,
    required this.cycleId,
    required this.userId,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  final String id;
  final String cycleId;
  final String userId;
  final int amount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final CycleBidUserModel user;

  factory CycleBidModel.fromJson(Map<String, dynamic> json) {
    return CycleBidModel(
      id: (json['id'] as String?) ?? '',
      cycleId: (json['cycleId'] as String?) ?? '',
      userId: (json['userId'] as String?) ?? '',
      amount: _toInt(json['amount']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      user: CycleBidUserModel.fromJson(
        (json['user'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      ),
    );
  }
}

int _toInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return 0;
}

DateTime? _parseDate(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
