import 'cycle_model.dart';

class CycleAuctionStateModel {
  const CycleAuctionStateModel({
    required this.cycleId,
    required this.auctionStatus,
    required this.selectedWinnerUserId,
    required this.finalPayoutUserId,
    required this.winningBidAmount,
    required this.winningBidUserId,
  });

  final String cycleId;
  final AuctionStatusModel auctionStatus;
  final String selectedWinnerUserId;
  final String finalPayoutUserId;
  final int? winningBidAmount;
  final String? winningBidUserId;

  factory CycleAuctionStateModel.fromJson(Map<String, dynamic> json) {
    return CycleAuctionStateModel(
      cycleId: (json['cycleId'] as String?) ?? '',
      auctionStatus: _parseAuctionStatus(json['auctionStatus']),
      selectedWinnerUserId:
          (json['selectedWinnerUserId'] as String?) ??
          (json['scheduledPayoutUserId'] as String?) ??
          '',
      finalPayoutUserId: (json['finalPayoutUserId'] as String?) ?? '',
      winningBidAmount: _toNullableInt(json['winningBidAmount']),
      winningBidUserId: json['winningBidUserId'] as String?,
    );
  }
}

AuctionStatusModel _parseAuctionStatus(Object? value) {
  final normalized = (value as String?)?.toUpperCase().trim();
  switch (normalized) {
    case 'NONE':
      return AuctionStatusModel.none;
    case 'OPEN':
      return AuctionStatusModel.open;
    case 'CLOSED':
      return AuctionStatusModel.closed;
    default:
      return AuctionStatusModel.unknown;
  }
}

int? _toNullableInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return null;
}
