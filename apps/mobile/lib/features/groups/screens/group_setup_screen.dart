import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/group_rules_model.dart';
import '../../../data/models/update_group_rules_request.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../group_rules_provider.dart';
import '../group_detail_controller.dart';

class GroupSetupScreen extends ConsumerStatefulWidget {
  const GroupSetupScreen({
    super.key,
    required this.groupId,
    this.initialStepKey,
  });

  final String groupId;
  final String? initialStepKey;

  @override
  ConsumerState<GroupSetupScreen> createState() => _GroupSetupScreenState();
}

class _GroupSetupScreenState extends ConsumerState<GroupSetupScreen> {
  static const List<_SetupTab> _setupTabs = [
    _SetupTab(
      key: 'basics',
      label: 'Basics',
      description: 'Set the contribution amount and round size.',
      section: _RulesSection.basics,
    ),
    _SetupTab(
      key: 'timing',
      label: 'Timing',
      description: 'Choose frequency, start policy, and start timing.',
      section: _RulesSection.timing,
    ),
    _SetupTab(
      key: 'policy',
      label: 'Policy',
      description: 'Set payout, fine, payment, and verification rules.',
      section: _RulesSection.policy,
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
  var _isSubmitting = false;
  var _currentStep = 0;
  var _isAnyRulesInputFocused = false;
  var _hasFatalLoadError = false;
  String? _errorMessage;

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
    _graceDaysFocusNode = FocusNode()..addListener(_handleRulesInputFocusChanged);
    _fineAmountFocusNode = FocusNode()..addListener(_handleRulesInputFocusChanged);
    _setupTabKeys = List<GlobalKey>.generate(_setupTabs.length, (_) => GlobalKey());
    _setupTabsScrollController = ScrollController();
    _currentStep = _initialStepFromKey(widget.initialStepKey);
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
    super.dispose();
  }

  int _initialStepFromKey(String? key) {
    final normalized = key?.trim().toLowerCase();
    final index = _setupTabs.indexWhere((tab) => tab.key == normalized);
    return index < 0 ? 0 : index;
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
    setState(() => _isAnyRulesInputFocused = isFocused);
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
      }
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      _scrollStepTabIntoView(_currentStep, animated: false);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = mapFriendlyError(error);
        _hasFatalLoadError = true;
      });
    }
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

  void _setCurrentStep(int step) {
    final target = step.clamp(0, _setupTabs.length - 1);
    setState(() {
      _currentStep = target;
      _errorMessage = null;
    });
    _scrollStepTabIntoView(target);
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
    return switch (_setupTabs[step].section) {
      _RulesSection.basics => _validateBasicsStep(),
      _RulesSection.timing => _validateTimingStep(),
      _RulesSection.policy => _validatePolicyStep(),
    };
  }

  bool _validateBasicsStep() {
    final contributionAmount = int.tryParse(_contributionAmountController.text.trim());
    final roundSize = int.tryParse(_roundSizeController.text.trim());
    if (contributionAmount == null || contributionAmount <= 0) {
      setState(() => _errorMessage = 'Contribution amount must be greater than 0.');
      return false;
    }
    if (roundSize == null || roundSize < 2) {
      setState(() => _errorMessage = 'Round size must be at least 2.');
      return false;
    }
    return true;
  }

  bool _validateTimingStep() {
    final roundSize = int.tryParse(_roundSizeController.text.trim()) ?? 2;
    final customIntervalDays = int.tryParse(_customIntervalDaysController.text.trim());
    final minToStart = int.tryParse(_minToStartController.text.trim());
    if (_frequency == GroupRuleFrequencyModel.customInterval &&
        (customIntervalDays == null || customIntervalDays <= 0)) {
      setState(() => _errorMessage = 'Custom interval days must be greater than 0.');
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

  bool _validatePolicyStep() {
    final graceDays = int.tryParse(_graceDaysController.text.trim());
    final fineAmount = int.tryParse(_fineAmountController.text.trim());
    if (graceDays == null || graceDays < 0) {
      setState(() => _errorMessage = 'Grace days must be 0 or higher.');
      return false;
    }
    if (_fineType == GroupRuleFineTypeModel.fixedAmount &&
        (fineAmount == null || fineAmount <= 0)) {
      setState(() => _errorMessage = 'Fine amount must be greater than 0 for fixed fines.');
      return false;
    }
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

  Future<void> _saveRules() async {
    if (!_validateBasicsStep() || !_validateTimingStep() || !_validatePolicyStep()) {
      return;
    }

    final contributionAmount = int.parse(_contributionAmountController.text.trim());
    final roundSize = int.parse(_roundSizeController.text.trim());
    final customIntervalDays = int.tryParse(_customIntervalDaysController.text.trim());
    final graceDays = int.parse(_graceDaysController.text.trim());
    final fineAmount = int.tryParse(_fineAmountController.text.trim()) ?? 0;
    final minToStart = int.tryParse(_minToStartController.text.trim());

    setState(() {
      _isSubmitting = true;
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
          fineAmount:
              _fineType == GroupRuleFineTypeModel.fixedAmount ? fineAmount : 0,
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

      ref.invalidate(groupRulesProvider(widget.groupId));
      await ref.read(groupDetailControllerProvider).refreshAll(widget.groupId);

      if (!mounted) {
        return;
      }

      AppSnackbars.success(context, 'Setup saved. Continue on the group page.');
      context.go(AppRoutePaths.groupDetail(widget.groupId));
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = mapFriendlyError(error);
      setState(() => _errorMessage = message);
      AppSnackbars.error(context, message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final hideBottomCta = isKeyboardOpen || _isAnyRulesInputFocused;

    return KitScaffold(
      appBar: KitAppBar(title: 'Group setup', subtitle: _stepSubtitle),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: _isLoading
            ? const LoadingView(message: 'Loading setup...')
            : _hasFatalLoadError && _errorMessage != null
            ? ErrorView(message: _errorMessage!, onRetry: _loadRules)
            : _buildBody(context, hideBottomCta: hideBottomCta),
      ),
    );
  }

  Widget _buildBody(BuildContext context, {required bool hideBottomCta}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          controller: _setupTabsScrollController,
          scrollDirection: Axis.horizontal,
          child: _buildStepTabs(context),
        ),
        const SizedBox(height: AppSpacing.md),
        Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
        const SizedBox(height: AppSpacing.md),
        Text(
          _setupTabs[_currentStep].description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: KitCard(
            child: SingleChildScrollView(
              child: _buildRulesStep(
                context,
                section: _setupTabs[_currentStep].section,
              ),
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            _errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        if (!hideBottomCta) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _attemptNavigateToStep(_currentStep - 1),
                    child: const Text('Back'),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: _isSubmitting
                      ? null
                      : (_currentStep == _setupTabs.length - 1
                            ? _saveRules
                            : () => _attemptNavigateToStep(_currentStep + 1)),
                  child: Text(
                    _currentStep == _setupTabs.length - 1
                        ? (_isSubmitting ? 'Saving...' : 'Save setup')
                        : 'Next',
                  ),
                ),
              ),
            ],
          ),
        ],
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
              isCompleted: index < _currentStep,
              onTap: () => _attemptNavigateToStep(index),
            ),
            if (index != _setupTabs.length - 1)
              _StepConnector(isActive: index < _currentStep),
          ],
        ],
      ),
    );
  }

  Widget _buildRulesStep(
    BuildContext context, {
    required _RulesSection section,
  }) {
    final roundSize = int.tryParse(_roundSizeController.text.trim()) ?? 2;
    final requiredToStart = _startPolicy == StartPolicyModel.whenFull
        ? roundSize
        : (int.tryParse(_minToStartController.text.trim()) ?? roundSize);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section == _RulesSection.basics) ...[
          AppTextField(
            controller: _contributionAmountController,
            focusNode: _contributionAmountFocusNode,
            label: 'Contribution amount',
            hint: '500',
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() => _errorMessage = null),
          ),
          const SizedBox(height: AppSpacing.md),
          KitDropdownField<int>(
            value: roundSize,
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
                final currentMin = int.tryParse(_minToStartController.text.trim());
                if (currentMin != null && currentMin > value) {
                  _minToStartController.text = '$value';
                }
                _errorMessage = null;
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          KitBanner(
            title: 'Basics summary',
            message: 'Each turn collects ${_contributionAmountController.text.trim().isEmpty ? '0' : _contributionAmountController.text.trim()} from up to $roundSize members.',
            tone: KitBadgeTone.info,
            icon: Icons.info_outline_rounded,
          ),
        ],
        if (section == _RulesSection.timing) ...[
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
                Text('Start date', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _startAt == null
                      ? 'Select a date'
                      : MaterialLocalizations.of(context).formatMediumDate(_startAt!),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startAt ?? now,
                      firstDate: now.subtract(const Duration(days: 1)),
                      lastDate: now.add(const Duration(days: 3650)),
                    );
                    if (!mounted || picked == null) {
                      return;
                    }
                    setState(() {
                      _startAt = DateTime(picked.year, picked.month, picked.day, 9);
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
              hint: '$roundSize',
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() => _errorMessage = null),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          KitBanner(
            title: 'Timing summary',
            message: _timingSummary(requiredToStart),
            tone: KitBadgeTone.info,
            icon: Icons.schedule_rounded,
          ),
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
          const SizedBox(height: AppSpacing.md),
          Text('Payment methods', style: Theme.of(context).textTheme.titleSmall),
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
            onChanged: (value) => setState(() {
              _requiresMemberVerification = value;
              _errorMessage = null;
            }),
          ),
          SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.only(left: AppSpacing.sm),
            title: const Text('Strict collection before payout'),
            value: _strictCollection,
            onChanged: (value) => setState(() {
              _strictCollection = value;
              _errorMessage = null;
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          KitBanner(
            title: 'Policy summary',
            message: _policySummary(),
            tone: KitBadgeTone.info,
            icon: Icons.verified_user_outlined,
          ),
        ],
      ],
    );
  }

  String _timingSummary(int requiredToStart) {
    final frequencyLabel = switch (_frequency) {
      GroupRuleFrequencyModel.weekly => 'Weekly',
      GroupRuleFrequencyModel.monthly => 'Monthly',
      GroupRuleFrequencyModel.customInterval =>
        'Every ${_customIntervalDaysController.text.trim().isEmpty ? '?' : _customIntervalDaysController.text.trim()} days',
      GroupRuleFrequencyModel.unknown => 'Custom',
    };

    final startLabel = switch (_startPolicy) {
      StartPolicyModel.whenFull => 'Starts when all $requiredToStart seats are filled',
      StartPolicyModel.manual => 'Starts manually once $requiredToStart members are ready',
      StartPolicyModel.onDate => _startAt == null
          ? 'Starts on a selected date'
          : 'Starts on ${MaterialLocalizations.of(context).formatMediumDate(_startAt!)}',
      StartPolicyModel.unknown => 'Start policy pending',
    };

    return '$frequencyLabel cadence. $startLabel.';
  }

  String _policySummary() {
    final payoutLabel = switch (_payoutMode) {
      GroupRulePayoutModeModel.lottery => 'Lottery payout',
      GroupRulePayoutModeModel.auction => 'Auction payout',
      GroupRulePayoutModeModel.rotation => 'Rotation payout',
      GroupRulePayoutModeModel.decision => 'Admin decision payout',
      GroupRulePayoutModeModel.unknown => 'Custom payout',
    };
    final fineLabel = switch (_fineType) {
      GroupRuleFineTypeModel.none => 'no late fine',
      GroupRuleFineTypeModel.fixedAmount =>
        'late fine ${_fineAmountController.text.trim().isEmpty ? '0' : _fineAmountController.text.trim()}',
      GroupRuleFineTypeModel.unknown => 'custom fine policy',
    };
    final verificationLabel = _requiresMemberVerification
        ? 'verification required before start'
        : 'joined members can count toward start';
    return '$payoutLabel, ${_graceDaysController.text.trim().isEmpty ? '0' : _graceDaysController.text.trim()} grace days, $fineLabel, $verificationLabel.';
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

  String get _stepSubtitle =>
      'Step ${_currentStep + 1} of ${_setupTabs.length}: ${_setupTabs[_currentStep].label}';
}

class _SetupTabButton extends StatelessWidget {
  const _SetupTabButton({
    super.key,
    required this.index,
    required this.tab,
    required this.isSelected,
    required this.isCompleted,
    required this.onTap,
  });

  final int index;
  final _SetupTab tab;
  final bool isSelected;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fillColor = isSelected
        ? colorScheme.primary
        : isCompleted
            ? colorScheme.primaryContainer
            : colorScheme.surface;
    final textColor = isSelected
        ? colorScheme.onPrimary
        : isCompleted
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurface;

    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isSelected
                    ? colorScheme.onPrimary.withValues(alpha: 0.14)
                    : colorScheme.surfaceContainerHighest,
                child: Text(
                  '${index + 1}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                tab.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      color: isActive
          ? colorScheme.primary
          : colorScheme.outlineVariant.withValues(alpha: 0.65),
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
    required this.key,
    required this.label,
    required this.description,
    required this.section,
  });

  final String key;
  final String label;
  final String description;
  final _RulesSection section;
}

enum _RulesSection { basics, timing, policy }
