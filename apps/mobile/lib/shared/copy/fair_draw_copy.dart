class FairDrawCopy {
  const FairDrawCopy._();

  static const label = '🎲 Fair Random Draw';

  static const compactExplanation = <String>[
    'Members are randomly ordered once.',
    'Each person gets exactly one turn.',
    'The order is locked after the draw.',
  ];

  static const startDialogTitle = label;
  static const startDialogBullets = <String>[
    'We will randomly order all active members once.',
    'Each member receives exactly one turn.',
    'The order can\'t be changed after starting.',
  ];
  static const startDialogCancel = 'Cancel';
  static const startDialogConfirm = 'Start round';

  static const roundOrderTitle = 'Round order';
  static const roundOrderSubtitle = 'Locked after the draw';
  static const howItWorksButton = 'How it works';
  static const shufflingLabel = 'Shuffling...';
  static const finalOrderLabel = 'Final order';
  static const replayLabel = 'Replay';

  static const emptyOrderTitle = 'No round order yet';
  static const emptyOrderMessage =
      'An admin can start ${FairDrawCopy.label} to lock the order for this round.';

  static const loadErrorTitle = 'Could not load round order';
  static const retryLabel = 'Retry';

  static const howItWorksTitle = label;
  static const howItWorksBullets = <String>[
    'We randomly order members once at the start.',
    'Each member appears exactly once.',
    'The order is locked for the round.',
  ];
  static const advancedLabel = 'Advanced';
  static const commitmentHashLabel = 'Draw commitment hash';
  static const copiedMessage = 'Copied';
}
