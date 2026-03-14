import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/models/public_group_model.dart';
import 'package:mobile/data/models/reputation_model.dart';
import 'package:mobile/features/groups/widgets/public_equb_card.dart';

void main() {
  Future<void> pumpCard(WidgetTester tester, PublicGroupModel group) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PublicEqubCard(group: group)),
      ),
    );
  }

  testWidgets('shows earned host title on discover cards', (tester) async {
    await pumpCard(
      tester,
      PublicGroupModel(
        id: 'group-1',
        name: 'Monthly Equb',
        currency: 'ETB',
        contributionAmount: 1000,
        frequency: PublicGroupFrequencyModel.monthly,
        memberCount: 16,
        alreadyStarted: false,
        hostName: 'Samuel',
        host: const HostReputationSummaryModel(
          userId: 'host-1',
          trustScore: 84,
          trustLevel: 'Trusted',
          summaryLabel: 'Pro',
          level: 'Pro',
          icon: '💎',
          displayLabel: 'Pro',
          hostTitle: 'Pro Host',
          equbsHosted: 2,
          hostedEqubsCompleted: 1,
          turnsParticipated: 3,
          cancelledGroupsCount: 0,
          hostDisputesCount: 0,
        ),
      ),
    );

    expect(find.text('Samuel'), findsOneWidget);
    expect(find.text('💎 Pro Host'), findsOneWidget);
  });

  testWidgets('hides host title when host has not earned reputation yet', (
    tester,
  ) async {
    await pumpCard(
      tester,
      PublicGroupModel(
        id: 'group-1',
        name: 'Monthly Equb',
        currency: 'ETB',
        contributionAmount: 1000,
        frequency: PublicGroupFrequencyModel.monthly,
        memberCount: 16,
        alreadyStarted: false,
        hostName: 'Samuel',
        host: const HostReputationSummaryModel(
          userId: 'host-1',
          trustScore: 50,
          trustLevel: 'New',
          equbsHosted: 0,
          hostedEqubsCompleted: 0,
          turnsParticipated: 0,
          cancelledGroupsCount: 0,
          hostDisputesCount: 0,
        ),
      ),
    );

    expect(find.text('Samuel'), findsOneWidget);
    expect(find.textContaining('Host'), findsNothing);
    expect(find.textContaining('Pro Host'), findsNothing);
    expect(find.textContaining('Rising'), findsNothing);
  });
}
