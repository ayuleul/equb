import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/group_rules_model.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/member_model.dart';
import '../../../data/models/member_status_utils.dart';
import '../../../data/models/update_group_rules_request.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/utils/api_error_mapper.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../data/api/api_error.dart';
import '../group_detail_controller.dart';

class GroupSetupScreen extends ConsumerStatefulWidget {
  const GroupSetupScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupSetupScreen> createState() => _GroupSetupScreenState();
}

class _GroupSetupScreenState extends ConsumerState<GroupSetupScreen> {
  static const int _rulesStepCount = 3;
  static const int _inviteStepIndex = 3;
  static const List<_SetupTab> _setupTabs = [
    _SetupTab(
      label: 'Basics',
      description: 'Round size and cycle start policy',
      section: _RulesSection.basics,
    ),
    _SetupTab(
      label: 'Timing',
      description: 'Amount, frequency, grace, and fines',
      section: _RulesSection.timing,
    ),
    _SetupTab(
      label: 'Policy',
      description: 'Payout mode and participation checks',
      section: _RulesSection.policy,
    ),
    _SetupTab(
      label: 'Invite & Verify',
      description: 'Generate invite and verify members',
    ),
  ];

  late final TextEditingController _contributionAmountController;
  late final TextEditingController _roundSizeController;
  late final TextEditingController _minToStartController;
  late final TextEditingController _customIntervalDaysController;
  late final TextEditingController _graceDaysController;
  late final TextEditingController _fineAmountController;
  late final FocusNode _contributionAmountFocusNode;
  late final FocusNode _minToStartFocusNode;
  late final FocusNode _customIntervalDaysFocusNode;
  late final FocusNode _graceDaysFocusNode;
  late final FocusNode _fineAmountFocusNode;
  late final List<GlobalKey> _setupTabKeys;
  late final ScrollController _setupTabsScrollController;
  late final PageController _detailsPageController;

  var _frequency = GroupRuleFrequencyModel.monthly;
  var _fineType = GroupRuleFineTypeModel.none;
  var _payoutMode = GroupRulePayoutModeModel.lottery;
  var _paymentMethods = <GroupPaymentMethodModel>{
    GroupPaymentMethodModel.cashAck,
  };
  var _requiresMemberVerification = false;
  var _strictCollection = false;
  var _startPolicy = StartPolicyModel.whenFull;
  DateTime? _startAt;

  var _isLoading = true;
  var _isSubmittingRules = false;
  var _isGeneratingInvite = false;
  String? _verifyingMemberId;
  String? _latestInviteCode;
  String? _latestInviteJoinUrl;
  String? _errorMessage;
  var _hasFatalLoadError = false;

  var _currentStep = 0;
  var _rulesSaved = false;
  var _isAnyRulesInputFocused = false;
  var _swipeDx = 0.0;
  var _swipeTriggered = false;

  @override
  void initState() {
    super.initState();
    _contributionAmountController = TextEditingController();
    _roundSizeController = TextEditingController(text: '2');
    _minToStartController = TextEditingController();
    _customIntervalDaysController = TextEditingController();
    _graceDaysController = TextEditingController(text: '0');
    _fineAmountController = TextEditingController(text: '0');
    _contributionAmountFocusNode = FocusNode()
      ..addListener(_handleRulesInputFocusChanged);
    _minToStartFocusNode = FocusNode()
      ..addListener(_handleRulesInputFocusChanged);
    _customIntervalDaysFocusNode = FocusNode()
      ..addListener(_handleRulesInputFocusChanged);
    _graceDaysFocusNode = FocusNode()
      ..addListener(_handleRulesInputFocusChanged);
    _fineAmountFocusNode = FocusNode()
      ..addListener(_handleRulesInputFocusChanged);
    _setupTabKeys = List<GlobalKey>.generate(
      _setupTabs.length,
      (_) => GlobalKey(),
    );
    _setupTabsScrollController = ScrollController();
    _detailsPageController = PageController();
    _loadRules();
  }

  @override
  void dispose() {
    _contributionAmountController.dispose();
    _roundSizeController.dispose();
    _minToStartController.dispose();
    _customIntervalDaysController.dispose();
    _graceDaysController.dispose();
    _fineAmountController.dispose();
    _contributionAmountFocusNode
      ..removeListener(_handleRulesInputFocusChanged)
      ..dispose();
    _minToStartFocusNode
      ..removeListener(_handleRulesInputFocusChanged)
      ..dispose();
    _customIntervalDaysFocusNode
      ..removeListener(_handleRulesInputFocusChanged)
      ..dispose();
    _graceDaysFocusNode
      ..removeListener(_handleRulesInputFocusChanged)
      ..dispose();
    _fineAmountFocusNode
      ..removeListener(_handleRulesInputFocusChanged)
      ..dispose();
    _setupTabsScrollController.dispose();
    _detailsPageController.dispose();
    super.dispose();
  }

  void _handleRulesInputFocusChanged() {
    final isFocused =
        _contributionAmountFocusNode.hasFocus ||
        _minToStartFocusNode.hasFocus ||
        _customIntervalDaysFocusNode.hasFocus ||
        _graceDaysFocusNode.hasFocus ||
        _fineAmountFocusNode.hasFocus;
    if (!mounted || _isAnyRulesInputFocused == isFocused) {
      return;
    }
    setState(() {
      _isAnyRulesInputFocused = isFocused;
    });
  }

  Future<void> _loadRules() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasFatalLoadError = false;
    });

    try {
      final repository = ref.read(groupsRepositoryProvider);
      final rules = await repository.getGroupRules(widget.groupId);
      if (rules != null) {
        _applyRules(rules);
        _rulesSaved = true;
        _currentStep = _inviteStepIndex;
      }
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      _scrollStepTabIntoView(_currentStep, animated: false);
      _syncDetailsPageToStep(_currentStep, animated: false);
    } catch (error) {
      if (!mounted) {
        return;
      }
      final apiError = error is ApiError ? error : null;
      if (apiError?.statusCode == 404 &&
          apiError!.message.toLowerCase().contains('rules')) {
        setState(() {
          _isLoading = false;
          _errorMessage = null;
          _hasFatalLoadError = false;
        });
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = mapApiErrorToMessage(error);
        _hasFatalLoadError = true;
      });
    }
  }

  int get _maxNavigableStep => _rulesSaved ? _inviteStepIndex : _rulesStepCount - 1;

  void _setCurrentStep(int step, {bool syncDetailsPage = true}) {
    final targetStep = step.clamp(0, _maxNavigableStep);
    setState(() {
      _currentStep = targetStep;
      _errorMessage = null;
    });
    _scrollStepTabIntoView(targetStep);
    if (syncDetailsPage) {
      _syncDetailsPageToStep(targetStep);
    }
  }

  bool _attemptNavigateToStep(int targetStep) {
    if (targetStep <= _currentStep) {
      _setCurrentStep(targetStep);
      return true;
    }
    for (var step = _currentStep; step < targetStep; step++) {
      if (!_validateStep(step)) {
        return false;
      }
    }
    _setCurrentStep(targetStep);
    return true;
  }

  bool _validateStep(int step) {
    if (step == 0) {
      return _validateBasicsStep();
    }
    if (step == 1) {
      return _validateTimingStep();
    }
    if (step == 2) {
      return _validatePolicyStep();
    }
    return true;
  }

  bool _validateBasicsStep() {
    final roundSize = int.tryParse(_roundSizeController.text.trim());
    final minToStart = int.tryParse(_minToStartController.text.trim());
    if (roundSize == null || roundSize < 2) {
      setState(() => _errorMessage = 'Round size must be at least 2.');
      return false;
    }
    if (_startPolicy == StartPolicyModel.onDate && _startAt == null) {
      setState(() => _errorMessage = 'Start date is required for ON_DATE policy.');
      return false;
    }
    if (_startPolicy != StartPolicyModel.whenFull &&
        _minToStartController.text.trim().isNotEmpty &&
        (minToStart == null || minToStart < 2 || minToStart > roundSize)) {
      setState(() => _errorMessage = 'Minimum to start must be between 2 and round size.');
      return false;
    }
    return true;
  }

  bool _validateTimingStep() {
    final contributionAmount = int.tryParse(_contributionAmountController.text.trim());
    final customIntervalDays = int.tryParse(_customIntervalDaysController.text.trim());
    final graceDays = int.tryParse(_graceDaysController.text.trim());
    final fineAmount = int.tryParse(_fineAmountController.text.trim());
    if (contributionAmount == null || contributionAmount <= 0) {
      setState(() => _errorMessage = 'Contribution amount must be greater than 0.');
      return false;
    }
    if (_frequency == GroupRuleFrequencyModel.customInterval &&
        (customIntervalDays == null || customIntervalDays <= 0)) {
      setState(() => _errorMessage = 'Custom interval days must be greater than 0.');
      return false;
    }
    if (graceDays == null || graceDays < 0) {
      setState(() => _errorMessage = 'Grace days must be 0 or higher.');
      return false;
    }
    if (_fineType == GroupRuleFineTypeModel.fixedAmount &&
        (fineAmount == null || fineAmount <= 0)) {
      setState(() => _errorMessage = 'Fine amount must be greater than 0 for fixed fines.');
      return false;
    }
    return true;
  }

  bool _validatePolicyStep() {
    if (_paymentMethods.isEmpty) {
      setState(() => _errorMessage = 'Select at least one payment method.');
      return false;
    }
    return true;
  }

  void _scrollStepTabIntoView(int index, {bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || index < 0 || index >= _setupTabKeys.length) {
        return;
      }
      final context = _setupTabKeys[index].currentContext;
      if (context == null) {
        return;
      }
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: animated ? const Duration(milliseconds: 140) : Duration.zero,
        curve: Curves.easeOut,
      );
    });
  }

  void _syncDetailsPageToStep(int step, {bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_detailsPageController.hasClients) {
        return;
      }
      final targetStep = step.clamp(0, _maxNavigableStep);
      final currentPage = (_detailsPageController.page ??
              _detailsPageController.initialPage.toDouble())
          .round();
      if (currentPage == targetStep) {
        return;
      }
      if (animated) {
        _detailsPageController.animateToPage(
          targetStep,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
        );
      } else {
        _detailsPageController.jumpToPage(targetStep);
      }
    });
  }

  void _onDetailsSwipeStart(DragStartDetails _) {
    _swipeDx = 0;
    _swipeTriggered = false;
  }

  void _onDetailsSwipeUpdate(DragUpdateDetails details) {
    if (_swipeTriggered) {
      return;
    }
    _swipeDx += details.delta.dx;
    if (_swipeDx <= -22 && _currentStep < _maxNavigableStep) {
      _swipeTriggered = true;
      _attemptNavigateToStep(_currentStep + 1);
      return;
    }
    if (_swipeDx >= 22 && _currentStep > 0) {
      _swipeTriggered = true;
      _attemptNavigateToStep(_currentStep - 1);
    }
  }

  void _onDetailsSwipeEnd(DragEndDetails _) {
    _swipeDx = 0;
    _swipeTriggered = false;
  }

  void _applyRules(GroupRulesModel rules) {
    _contributionAmountController.text = '${rules.contributionAmount}';
    _roundSizeController.text = '${rules.roundSize}';
    _minToStartController.text = rules.minToStart?.toString() ?? '';
    _customIntervalDaysController.text =
        rules.customIntervalDays?.toString() ?? '';
    _graceDaysController.text = '${rules.graceDays}';
    _fineAmountController.text = '${rules.fineAmount}';
    _frequency = rules.frequency;
    _fineType = rules.fineType;
    _payoutMode = rules.payoutMode;
    _paymentMethods = rules.paymentMethods.toSet();
    _requiresMemberVerification = rules.requiresMemberVerification;
    _strictCollection = rules.strictCollection;
    _startPolicy = rules.startPolicy;
    _startAt = rules.startAt;
  }

  Future<void> _saveRulesAndContinue() async {
    final contributionAmount = int.tryParse(
      _contributionAmountController.text.trim(),
    );
    final roundSize = int.tryParse(_roundSizeController.text.trim());
    final minToStart = int.tryParse(_minToStartController.text.trim());
    final customIntervalDays = int.tryParse(
      _customIntervalDaysController.text.trim(),
    );
    final graceDays = int.tryParse(_graceDaysController.text.trim());
    final fineAmount = int.tryParse(_fineAmountController.text.trim());

    if (contributionAmount == null || contributionAmount <= 0) {
      setState(() {
        _errorMessage = 'Contribution amount must be greater than 0.';
      });
      return;
    }

    if (roundSize == null || roundSize < 2) {
      setState(() {
        _errorMessage = 'Round size must be at least 2.';
      });
      return;
    }

    if (graceDays == null || graceDays < 0) {
      setState(() {
        _errorMessage = 'Grace days must be 0 or higher.';
      });
      return;
    }

    if (_frequency == GroupRuleFrequencyModel.customInterval &&
        (customIntervalDays == null || customIntervalDays <= 0)) {
      setState(() {
        _errorMessage = 'Custom interval days must be greater than 0.';
      });
      return;
    }

    if (_fineType == GroupRuleFineTypeModel.fixedAmount &&
        (fineAmount == null || fineAmount <= 0)) {
      setState(() {
        _errorMessage = 'Fine amount must be greater than 0 for fixed fines.';
      });
      return;
    }

    if (_paymentMethods.isEmpty) {
      setState(() {
        _errorMessage = 'Select at least one payment method.';
      });
      return;
    }

    if (_startPolicy == StartPolicyModel.onDate && _startAt == null) {
      setState(() {
        _errorMessage = 'Start date is required for ON_DATE policy.';
      });
      return;
    }

    if (_startPolicy != StartPolicyModel.whenFull &&
        _minToStartController.text.trim().isNotEmpty) {
      if (minToStart == null || minToStart < 2 || minToStart > roundSize) {
        setState(() {
          _errorMessage = 'Minimum to start must be between 2 and round size.';
        });
        return;
      }
    }

    setState(() {
      _isSubmittingRules = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(groupsRepositoryProvider);
      await repository.upsertGroupRules(
        widget.groupId,
        UpdateGroupRulesRequest(
          contributionAmount: contributionAmount,
          frequency: _frequency,
          customIntervalDays:
              _frequency == GroupRuleFrequencyModel.customInterval
              ? customIntervalDays
              : null,
          graceDays: graceDays,
          fineType: _fineType,
          fineAmount: _fineType == GroupRuleFineTypeModel.fixedAmount
              ? (fineAmount ?? 0)
              : 0,
          payoutMode: _payoutMode,
          paymentMethods: _paymentMethods.toList(growable: false),
          requiresMemberVerification: _requiresMemberVerification,
          strictCollection: _strictCollection,
          startPolicy: _startPolicy,
          roundSize: roundSize,
          startAt: _startPolicy == StartPolicyModel.onDate ? _startAt : null,
          minToStart: _startPolicy == StartPolicyModel.whenFull
              ? null
              : (_minToStartController.text.trim().isEmpty ? null : minToStart),
        ),
      );

      await ref.read(groupDetailControllerProvider).refreshAll(widget.groupId);

      if (!mounted) {
        return;
      }

      setState(() => _rulesSaved = true);
      _setCurrentStep(_inviteStepIndex);

      AppSnackbars.success(
        context,
        'Rules saved. Continue with invite and verification.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = mapApiErrorToMessage(error);
      setState(() {
        _errorMessage = message;
      });
      AppSnackbars.error(context, message);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingRules = false;
        });
      }
    }
  }

  Future<void> _createInvite() async {
    if (!_rulesSaved) {
      return;
    }

    setState(() {
      _isGeneratingInvite = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(groupsRepositoryProvider);
      final invite = await repository.createInvite(widget.groupId);
      if (!mounted) {
        return;
      }

      setState(() {
        _latestInviteCode = invite.code;
        _latestInviteJoinUrl = invite.joinUrl;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = mapApiErrorToMessage(error);
      setState(() {
        _errorMessage = message;
      });
      AppSnackbars.error(context, message);
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingInvite = false;
        });
      }
    }
  }

  Future<void> _verifyMember(MemberModel member) async {
    if (_verifyingMemberId != null) {
      return;
    }

    setState(() {
      _verifyingMemberId = member.id;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(groupsRepositoryProvider);
      await repository.verifyMember(widget.groupId, member.id);
      await ref.read(groupDetailControllerProvider).refreshAll(widget.groupId);

      if (!mounted) {
        return;
      }

      AppSnackbars.success(context, '${member.displayName} verified.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = mapApiErrorToMessage(error);
      setState(() {
        _errorMessage = message;
      });
      AppSnackbars.error(context, message);
    } finally {
      if (mounted) {
        setState(() {
          _verifyingMemberId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(groupDetailProvider(widget.groupId));
    final membersAsync = ref.watch(groupMembersProvider(widget.groupId));

    return KitScaffold(
      appBar: KitAppBar(
        title: 'Group setup',
        subtitle: _stepSubtitle,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: _buildBody(context, groupAsync, membersAsync),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncValue<GroupModel> groupAsync,
    AsyncValue<List<MemberModel>> membersAsync,
  ) {
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final hideSaveRulesCta = isKeyboardOpen || _isAnyRulesInputFocused;

    if (_isLoading) {
      return const LoadingView(message: 'Loading setup...');
    }

    if (_hasFatalLoadError && _errorMessage != null) {
      return ErrorView(message: _errorMessage!, onRetry: _loadRules);
    }

    final members = membersAsync.valueOrNull ?? const <MemberModel>[];
    final participatingMembers = members
        .where((member) => isParticipatingMemberStatus(member.status))
        .length;
    final verifiedMembers = members
        .where((member) => isVerifiedMemberStatus(member.status))
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                controller: _setupTabsScrollController,
                scrollDirection: Axis.horizontal,
                child: _buildStepTabs(context),
              ),
              const SizedBox(height: AppSpacing.md),
              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _setupTabs[_currentStep].description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragStart: _onDetailsSwipeStart,
                    onHorizontalDragUpdate: _onDetailsSwipeUpdate,
                    onHorizontalDragEnd: _onDetailsSwipeEnd,
                    child: KitCard(
                      child: PageView.builder(
                        controller: _detailsPageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _rulesSaved ? _setupTabs.length : _rulesStepCount,
                        onPageChanged: (index) =>
                            _setCurrentStep(index, syncDetailsPage: false),
                        itemBuilder: (context, index) {
                          return SingleChildScrollView(
                            key: PageStorageKey('group-setup-page-$index'),
                            child: index == _inviteStepIndex
                                ? _buildInviteVerifyStep(
                                    context,
                                    groupAsync,
                                    membersAsync,
                                    participatingMembers,
                                    verifiedMembers,
                                  )
                                : _buildRulesStep(
                                    context,
                                    participatingMembers,
                                    verifiedMembers,
                                    section: _setupTabs[index].section!,
                                  ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_errorMessage != null) ...[
          Text(
            _errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (!hideSaveRulesCta && _currentStep <= _rulesStepCount - 1)
          Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _attemptNavigateToStep(_currentStep - 1);
                    },
                    child: const Text('Back'),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: _isSubmittingRules
                      ? null
                      : (_currentStep == _rulesStepCount - 1
                            ? _saveRulesAndContinue
                            : () {
                                _attemptNavigateToStep(_currentStep + 1);
                              }),
                  child: Text(
                    _currentStep == _rulesStepCount - 1
                        ? (_isSubmittingRules ? 'Saving...' : 'Save rules')
                        : 'Next',
                  ),
                ),
              ),
            ],
          ),
        if (_currentStep == _inviteStepIndex)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () =>
                  context.go(AppRoutePaths.groupDetail(widget.groupId)),
              icon: const Icon(Icons.task_alt_rounded),
              label: const Text('Finish setup'),
            ),
          ),
      ],
    );
  }

  Widget _buildStepTabs(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          for (var index = 0; index < _setupTabs.length; index++) ...[
            _SetupTabButton(
              key: _setupTabKeys[index],
              index: index,
              tab: _setupTabs[index],
              isSelected: _currentStep == index,
              isCompleted:
                  index < _currentStep ||
                  (_rulesSaved && index < _inviteStepIndex),
              isLocked: index == _inviteStepIndex && !_rulesSaved,
              onTap: () => _attemptNavigateToStep(index),
            ),
            if (index != _setupTabs.length - 1)
              _StepConnector(
                isActive: index < _currentStep,
                isLocked: !_rulesSaved && index >= _rulesStepCount - 1,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildRulesStep(
    BuildContext context,
    int participatingMembers,
    int verifiedMembers,
    {required _RulesSection section}
  ) {
    final effectiveMinToStart = _startPolicy == StartPolicyModel.whenFull
        ? null
        : int.tryParse(_minToStartController.text.trim());
    final requiredToStart = _startPolicy == StartPolicyModel.whenFull
        ? int.tryParse(_roundSizeController.text.trim()) ?? 2
        : (effectiveMinToStart ??
              (int.tryParse(_roundSizeController.text.trim()) ?? 2));
    final eligibleCount = _requiresMemberVerification
        ? verifiedMembers
        : participatingMembers;
    final waitingForMembers = _startPolicy == StartPolicyModel.whenFull
        ? eligibleCount != requiredToStart
        : eligibleCount < requiredToStart;
    final waitingForDate =
        _startPolicy == StartPolicyModel.onDate &&
        !waitingForMembers &&
        _startAt != null &&
        DateTime.now().isBefore(_startAt!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section == _RulesSection.basics) ...[
          KitDropdownField<int>(
            value: int.tryParse(_roundSizeController.text.trim()) ?? 2,
            label: 'Round size',
            items: List<DropdownMenuItem<int>>.generate(
              29,
              (index) => DropdownMenuItem<int>(
                value: index + 2,
                child: Text('${index + 2} members'),
              ),
            ),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _roundSizeController.text = '$value';
                if (_minToStartController.text.trim().isNotEmpty) {
                  final currentMin = int.tryParse(
                    _minToStartController.text.trim(),
                  );
                  if (currentMin != null && currentMin > value) {
                    _minToStartController.text = '$value';
                  }
                }
                _errorMessage = null;
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          KitDropdownField<StartPolicyModel>(
            value: _startPolicy,
            label: 'Start policy',
            items: const [
              DropdownMenuItem(
                value: StartPolicyModel.whenFull,
                child: Text('WHEN_FULL'),
              ),
              DropdownMenuItem(
                value: StartPolicyModel.onDate,
                child: Text('ON_DATE'),
              ),
              DropdownMenuItem(
                value: StartPolicyModel.manual,
                child: Text('MANUAL'),
              ),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _startPolicy = value;
                if (_startPolicy != StartPolicyModel.onDate) {
                  _startAt = null;
                }
                if (_startPolicy == StartPolicyModel.whenFull) {
                  _minToStartController.clear();
                }
                _errorMessage = null;
              });
            },
          ),
          if (_startPolicy == StartPolicyModel.onDate) ...[
            const SizedBox(height: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start date',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _startAt == null
                      ? 'Select a date'
                      : MaterialLocalizations.of(
                          context,
                        ).formatMediumDate(_startAt!),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final initialDate = _startAt ?? now;
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: now.subtract(const Duration(days: 1)),
                      lastDate: now.add(const Duration(days: 3650)),
                    );
                    if (!mounted || picked == null) {
                      return;
                    }
                    setState(() {
                      _startAt = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        9,
                      );
                      _errorMessage = null;
                    });
                  },
                  child: const Text('Pick date'),
                ),
              ],
            ),
          ],
          if (_startPolicy != StartPolicyModel.whenFull) ...[
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _minToStartController,
              focusNode: _minToStartFocusNode,
              label: 'Minimum to start (optional)',
              labelTooltip: 'Leave blank to use round size as the minimum.',
              hint: _roundSizeController.text.trim().isEmpty
                  ? '2'
                  : _roundSizeController.text.trim(),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() => _errorMessage = null),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          KitBanner(
            title: 'Start preview',
            message: waitingForDate
                ? 'Eligible: $eligibleCount/$requiredToStart. Waiting for the configured start date.'
                : waitingForMembers
                ? 'Eligible: $eligibleCount/$requiredToStart. Waiting for more members.'
                : 'Eligible: $eligibleCount/$requiredToStart. Ready to start.',
            tone: (!waitingForMembers && !waitingForDate)
                ? KitBadgeTone.success
                : KitBadgeTone.warning,
            icon: (!waitingForMembers && !waitingForDate)
                ? Icons.check_circle_outline
                : Icons.info_outline_rounded,
          ),
        ],
        if (section == _RulesSection.timing) ...[
          AppTextField(
            controller: _contributionAmountController,
            focusNode: _contributionAmountFocusNode,
            label: 'Contribution amount',
            hint: '500',
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() => _errorMessage = null),
          ),
          const SizedBox(height: AppSpacing.md),
          KitDropdownField<GroupRuleFrequencyModel>(
            value: _frequency,
            label: 'Frequency',
            items: const [
              DropdownMenuItem(
                value: GroupRuleFrequencyModel.weekly,
                child: Text('WEEKLY'),
              ),
              DropdownMenuItem(
                value: GroupRuleFrequencyModel.monthly,
                child: Text('MONTHLY'),
              ),
              DropdownMenuItem(
                value: GroupRuleFrequencyModel.customInterval,
                child: Text('CUSTOM_INTERVAL'),
              ),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _frequency = value;
                _errorMessage = null;
              });
            },
          ),
          if (_frequency == GroupRuleFrequencyModel.customInterval) ...[
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _customIntervalDaysController,
              focusNode: _customIntervalDaysFocusNode,
              label: 'Custom interval (days)',
              hint: '14',
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() => _errorMessage = null),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _graceDaysController,
            focusNode: _graceDaysFocusNode,
            label: 'Grace days',
            labelTooltip:
                'Days allowed after the due date before a contribution is marked late.',
            hint: '2',
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() => _errorMessage = null),
          ),
          const SizedBox(height: AppSpacing.md),
          KitDropdownField<GroupRuleFineTypeModel>(
            value: _fineType,
            label: 'Fine policy',
            items: const [
              DropdownMenuItem(
                value: GroupRuleFineTypeModel.none,
                child: Text('NONE'),
              ),
              DropdownMenuItem(
                value: GroupRuleFineTypeModel.fixedAmount,
                child: Text('FIXED_AMOUNT'),
              ),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _fineType = value;
                _errorMessage = null;
              });
            },
          ),
          if (_fineType == GroupRuleFineTypeModel.fixedAmount) ...[
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _fineAmountController,
              focusNode: _fineAmountFocusNode,
              label: 'Fine amount',
              hint: '50',
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() => _errorMessage = null),
            ),
          ],
        ],
        if (section == _RulesSection.policy) ...[
          KitDropdownField<GroupRulePayoutModeModel>(
            value: _payoutMode,
            label: 'Payout mode',
            items: const [
              DropdownMenuItem(
                value: GroupRulePayoutModeModel.lottery,
                child: Text('LOTTERY'),
              ),
              DropdownMenuItem(
                value: GroupRulePayoutModeModel.auction,
                child: Text('AUCTION'),
              ),
              DropdownMenuItem(
                value: GroupRulePayoutModeModel.rotation,
                child: Text('ROTATION'),
              ),
              DropdownMenuItem(
                value: GroupRulePayoutModeModel.decision,
                child: Text('DECISION'),
              ),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _payoutMode = value;
                _errorMessage = null;
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Payment methods',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          _PaymentMethodTile(
            label: 'BANK',
            value: GroupPaymentMethodModel.bank,
            selectedMethods: _paymentMethods,
            onChanged: _togglePaymentMethod,
          ),
          _PaymentMethodTile(
            label: 'TELEBIRR',
            value: GroupPaymentMethodModel.telebirr,
            selectedMethods: _paymentMethods,
            onChanged: _togglePaymentMethod,
          ),
          _PaymentMethodTile(
            label: 'CASH_ACK',
            value: GroupPaymentMethodModel.cashAck,
            selectedMethods: _paymentMethods,
            onChanged: _togglePaymentMethod,
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.only(left: AppSpacing.sm),
            title: const Text('Requires member verification'),
            value: _requiresMemberVerification,
            onChanged: (value) {
              setState(() {
                _requiresMemberVerification = value;
              });
            },
          ),
          SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.only(left: AppSpacing.sm),
            title: const Text('Strict collection before payout'),
            value: _strictCollection,
            onChanged: (value) {
              setState(() {
                _strictCollection = value;
              });
            },
          ),
        ],
      ],
    );
  }

  String get _stepSubtitle => switch (_currentStep) {
    0 => 'Step 1 of 4: Basics',
    1 => 'Step 2 of 4: Timing',
    2 => 'Step 3 of 4: Policy',
    _ => 'Step 4 of 4: Invite & Verify',
  };

  Widget _buildInviteVerifyStep(
    BuildContext context,
    AsyncValue<GroupModel> groupAsync,
    AsyncValue<List<MemberModel>> membersAsync,
    int participatingMembers,
    int verifiedMembers,
  ) {
    if (!_rulesSaved) {
      return Text(
        'Save rules first to unlock member invite and verification.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final requiresVerification = _requiresMemberVerification;
    final eligibleCount = requiresVerification
        ? verifiedMembers
        : participatingMembers;
    final roundSize = int.tryParse(_roundSizeController.text.trim()) ?? 2;
    final minimumFromInput = int.tryParse(_minToStartController.text.trim());
    final requiredToStart = _startPolicy == StartPolicyModel.whenFull
        ? roundSize
        : (minimumFromInput ?? roundSize);
    final missingCount = eligibleCount >= requiredToStart
        ? 0
        : requiredToStart - eligibleCount;
    final waitingForDate =
        missingCount == 0 &&
        _startPolicy == StartPolicyModel.onDate &&
        _startAt != null &&
        DateTime.now().isBefore(_startAt!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton.icon(
          onPressed: _isGeneratingInvite ? null : _createInvite,
          icon: const Icon(Icons.qr_code_2_outlined),
          label: Text(
            _latestInviteCode == null
                ? (_isGeneratingInvite
                      ? 'Generating...'
                      : 'Generate invite code')
                : (_isGeneratingInvite ? 'Generating...' : 'Generate new code'),
          ),
        ),
        if (_latestInviteCode != null) ...[
          const SizedBox(height: AppSpacing.md),
          KitCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current invite code',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                SelectableText(
                  _latestInviteCode!,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: _latestInviteCode!),
                    );
                    if (!context.mounted) {
                      return;
                    }
                    AppSnackbars.success(context, 'Invite code copied');
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy code'),
                ),
                if (_latestInviteJoinUrl != null &&
                    _latestInviteJoinUrl!.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Join URL',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SelectableText(_latestInviteJoinUrl!),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        KitBanner(
          title: 'Cycle start gate',
          message: missingCount == 0 && _startPolicy == StartPolicyModel.onDate
              ? waitingForDate
                    ? 'Eligible members: $eligibleCount/$requiredToStart. Waiting for start date.'
                    : 'Eligible members: $eligibleCount/$requiredToStart (ready to start cycles).'
              : missingCount == 0
              ? 'Eligible members: $eligibleCount/$requiredToStart (ready to start cycles).'
              : requiresVerification
              ? 'Need $missingCount more verified member(s). Eligible now: $eligibleCount/$requiredToStart.'
              : 'Need $missingCount more joined member(s). Eligible now: $eligibleCount/$requiredToStart.',
          tone: (missingCount == 0 && !waitingForDate)
              ? KitBadgeTone.success
              : KitBadgeTone.warning,
          icon: (missingCount == 0 && !waitingForDate)
              ? Icons.verified_outlined
              : Icons.info_outline_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        const KitSectionHeader(title: 'Members'),
        membersAsync.when(
          loading: () =>
              const SizedBox(height: 220, child: KitSkeletonList(itemCount: 4)),
          error: (error, _) => ErrorView(
            message: mapFriendlyError(error),
            onRetry: () => ref
                .read(groupDetailControllerProvider)
                .refreshMembers(widget.groupId),
          ),
          data: (members) {
            if (members.isEmpty) {
              return const KitEmptyState(
                icon: Icons.people_outline,
                title: 'No members yet',
                message: 'Invite members, then verify them when they join.',
              );
            }

            final group = groupAsync.valueOrNull;
            final isAdmin = group?.membership?.role == MemberRoleModel.admin;

            return KitCard(
              child: Column(
                children: [
                  for (var index = 0; index < members.length; index++) ...[
                    _SetupMemberRow(
                      member: members[index],
                      canVerify:
                          isAdmin &&
                          (members[index].status == MemberStatusModel.joined ||
                              members[index].status ==
                                  MemberStatusModel.invited ||
                              members[index].status ==
                                  MemberStatusModel.active),
                      isVerifying: _verifyingMemberId == members[index].id,
                      onVerify: () => _verifyMember(members[index]),
                    ),
                    if (index != members.length - 1)
                      Divider(
                        height: AppSpacing.lg,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _togglePaymentMethod(GroupPaymentMethodModel method, bool isSelected) {
    setState(() {
      if (isSelected) {
        _paymentMethods = {..._paymentMethods, method};
      } else {
        _paymentMethods = {..._paymentMethods}..remove(method);
      }
      _errorMessage = null;
    });
  }
}

class _SetupMemberRow extends StatelessWidget {
  const _SetupMemberRow({
    required this.member,
    required this.canVerify,
    required this.isVerifying,
    required this.onVerify,
  });

  final MemberModel member;
  final bool canVerify;
  final bool isVerifying;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final roleLabel = switch (member.role) {
      MemberRoleModel.admin => 'ADMIN',
      MemberRoleModel.member => 'MEMBER',
      MemberRoleModel.unknown => 'UNKNOWN',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            KitAvatar(name: member.displayName, size: KitAvatarSize.sm),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (member.verifiedAt != null)
                    Text(
                      'Verified ${member.verifiedAt!.toLocal()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            StatusPill.fromLabel(roleLabel),
            StatusPill.fromLabel(memberStatusLabel(member.status)),
            if (canVerify)
              TextButton(
                onPressed: isVerifying ? null : onVerify,
                child: Text(isVerifying ? 'Verifying...' : 'Verify'),
              ),
          ],
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.label,
    required this.value,
    required this.selectedMethods,
    required this.onChanged,
  });

  final String label;
  final GroupPaymentMethodModel value;
  final Set<GroupPaymentMethodModel> selectedMethods;
  final void Function(GroupPaymentMethodModel method, bool isSelected)
  onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: selectedMethods.contains(value),
      contentPadding: const EdgeInsets.only(left: AppSpacing.sm),
      title: Text(label),
      onChanged: (checked) => onChanged(value, checked ?? false),
    );
  }
}

class _SetupTab {
  const _SetupTab({
    required this.label,
    required this.description,
    this.section,
  });

  final String label;
  final String description;
  final _RulesSection? section;
}

enum _RulesSection { basics, timing, policy }

class _SetupTabButton extends StatelessWidget {
  const _SetupTabButton({
    super.key,
    required this.index,
    required this.tab,
    required this.isSelected,
    required this.isCompleted,
    required this.isLocked,
    required this.onTap,
  });

  final int index;
  final _SetupTab tab;
  final bool isSelected;
  final bool isCompleted;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = isSelected
        ? colorScheme.onPrimary
        : isLocked
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurface;
    final background = isSelected ? colorScheme.primary : Colors.transparent;
    final indicatorBackground = isSelected
        ? colorScheme.onPrimary.withValues(alpha: 0.18)
        : colorScheme.surfaceContainerHighest;
    final indicatorBorder = isSelected
        ? colorScheme.primary
        : isCompleted
        ? colorScheme.primary
        : colorScheme.outlineVariant;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: isLocked
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap();
              },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: indicatorBackground,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: indicatorBorder),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tab.label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isLocked) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 14,
                      color: foreground,
                    ),
                  ] else if (isCompleted && !isSelected) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector({required this.isActive, required this.isLocked});

  final bool isActive;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isActive
        ? colorScheme.primary
        : isLocked
        ? colorScheme.outlineVariant.withValues(alpha: 0.55)
        : colorScheme.outlineVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: 12,
        child: Divider(
          color: color,
          thickness: 1.3,
          height: 1,
        ),
      ),
    );
  }
}
