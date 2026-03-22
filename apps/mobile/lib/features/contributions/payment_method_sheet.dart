import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../data/models/group_rules_model.dart';
import '../../shared/kit/kit.dart';

List<GroupPaymentMethodModel> supportedContributionPaymentMethods(
  GroupRulesModel? rules,
) {
  final methods =
      rules?.paymentMethods
          .where(
            (method) =>
                method == GroupPaymentMethodModel.cashAck ||
                method == GroupPaymentMethodModel.telebirr,
          )
          .toSet()
          .toList(growable: false) ??
      const <GroupPaymentMethodModel>[
        GroupPaymentMethodModel.cashAck,
        GroupPaymentMethodModel.telebirr,
      ];

  if (methods.isEmpty) {
    return const <GroupPaymentMethodModel>[GroupPaymentMethodModel.cashAck];
  }

  methods.sort((left, right) {
    final leftRank = left == GroupPaymentMethodModel.cashAck ? 0 : 1;
    final rightRank = right == GroupPaymentMethodModel.cashAck ? 0 : 1;
    return leftRank.compareTo(rightRank);
  });
  return methods;
}

Future<void> showContributionPaymentMethodSheet(
  BuildContext context, {
  required String groupId,
  required String cycleId,
  required List<GroupPaymentMethodModel> supportedMethods,
}) {
  return KitActionSheet.show(
    context: context,
    title: 'Choose payment method',
    actions: supportedMethods
        .map(
          (method) => KitActionSheetItem(
            label: _paymentMethodLabel(method),
            icon: switch (method) {
              GroupPaymentMethodModel.cashAck => Icons.handshake_outlined,
              GroupPaymentMethodModel.telebirr => Icons.phone_android,
              _ => Icons.payments_outlined,
            },
            onPressed: () => context.push(
              AppRoutePaths.groupCycleContributionsSubmit(
                groupId,
                cycleId,
                method: contributionPaymentMethodRouteKey(method),
              ),
            ),
          ),
        )
        .toList(growable: false),
  );
}

String contributionPaymentMethodRouteKey(GroupPaymentMethodModel method) {
  return switch (method) {
    GroupPaymentMethodModel.cashAck => 'manual',
    GroupPaymentMethodModel.telebirr => 'telebirr',
    _ => '',
  };
}

String _paymentMethodLabel(GroupPaymentMethodModel method) {
  return switch (method) {
    GroupPaymentMethodModel.telebirr => 'Telebirr',
    GroupPaymentMethodModel.cashAck => 'Manual',
    GroupPaymentMethodModel.bank => 'Bank',
    GroupPaymentMethodModel.unknown => 'Unknown',
  };
}
