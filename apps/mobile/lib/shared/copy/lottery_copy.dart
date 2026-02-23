class LotteryCopy {
  const LotteryCopy._();

  static const label = '🎲 Lottery';
  static const drawWinnerButton = 'Start cycle';
  static const drawingWinnerLabel = 'Starting cycle...';
  static const drawingWinnerDialogLabel = 'Starting cycle…';
  static const drawSuccessPrefix = '🎉';
  static const winnerHeadline = '🎲 This turn\'s winner';
  static const drawSuccessMessageSuffix = 'won this turn!';

  static const startDialogTitle = '🎲 Lottery';
  static const startDialogCancel = 'Cancel';
  static const startDialogConfirm = 'Start round';
  static const startDialogBullets = <String>[
    'We will randomly pick one winner each turn.',
    'Each member receives exactly one turn per round.',
    'Future winners are not shown in advance.',
  ];
  static const startedMessage = '🎲 Lottery started.';

  static const summaryTitle = 'Lottery summary';
  static const turnsCompletedLabel = 'Lottery turns completed';
  static const lastWinnerLabel = 'Last winner';
  static const statusLabel = 'Current round status';
  static const statusInProgress = 'In progress';
  static const statusCompleted = 'Completed';
  static const completedRoundMessage =
      'All members have received once. You can start a new round.';

  static const noTurnYetTitle = 'Current turn';
  static const noTurnYetMessage =
      'No open turn right now. Admin can start the next cycle.';
  static const noWinnerYet = 'No winner yet';

  static const noOpenTurnMessage =
      'No open turn right now. Start a cycle to begin this turn.';
  static const roundCompletedTitle = 'Round completed';
  static const roundCompletedMessage =
      'All members have received once. Start a new round to continue.';
}
