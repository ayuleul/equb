import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/group_rules_model.dart';
import '../../../data/models/update_group_rules_request.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/utils/api_error_mapper.dart';
import '../../../shared/utils/reputation_presenter.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../group_rules_provider.dart';
import '../group_detail_controller.dart';
import '../../profile/profile_reputation_provider.dart';

class GroupSetupScreen extends ConsumerStatefulWidget {
  const GroupSetupScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupSetupScreen> createState() => _GroupSetupScreenState();
}

class _GroupSetupScreenState extends ConsumerState<GroupSetupScreen> {
  late final TextEditingController _contributionAmountController;
  late final TextEditingController _groupNameController;
  late final TextEditingController _groupDescriptionController;
  late final TextEditingController _currencyController;
  late final TextEditingController _roundSizeController;
  late final TextEditingController _customIntervalDaysController;
  late final TextEditingController _graceDaysController;
  late final TextEditingController _fineAmountController;
  late final FocusNode _contributionAmountFocusNode;
  late final FocusNode _groupNameFocusNode;
  late final FocusNode _groupDescriptionFocusNode;
  late final FocusNode _currencyFocusNode;
  late final FocusNode _customIntervalDaysFocusNode;
  late final FocusNode _graceDaysFocusNode;
  late final FocusNode _fineAmountFocusNode;

  var _visibility = GroupVisibilityModel.private;
  var _frequency = GroupRuleFrequencyModel.monthly;
  var _fineType = GroupRuleFineTypeModel.none;
  var _payoutMode = GroupRulePayoutModeModel.lottery;
  var _winnerSelectionTiming = WinnerSelectionTimingModel.beforeCollection;
  var _paymentMethods = <GroupPaymentMethodModel>{
    GroupPaymentMethodModel.cashAck,
  };

  var _isLoading = true;
  var _isSubmitting = false;
  var _isAnyRulesInputFocused = false;
  var _hasFatalLoadError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _groupNameController = TextEditingController();
    _groupDescriptionController = TextEditingController();
    _currencyController = TextEditingController();
    _contributionAmountController = TextEditingController();
    _roundSizeController = TextEditingController(text: '2');
    _customIntervalDaysController = TextEditingController();
    _graceDaysController = TextEditingController(text: '0');
    _fineAmountController = TextEditingController(text: '0');
    _contributionAmountFocusNode = FocusNode()
      ..addListener(_handleRulesInputFocusChanged);
    _groupNameFocusNode = FocusNode()
      ..addListener(_handleRulesInputFocusChanged);
    _groupDescriptionFocusNode = FocusNode()
      ..addListener(_handleRulesInputFocusChanged);
    _currencyFocusNode = FocusNode()
      ..addListener(_handleRulesInputFocusChanged);
    _customIntervalDaysFocusNode = FocusNode()
      ..addListener(_handleRulesInputFocusChanged);
    _graceDaysFocusNode = FocusNode()
      ..addListener(_handleRulesInputFocusChanged);
    _fineAmountFocusNode = FocusNode()
      ..addListener(_handleRulesInputFocusChanged);
    _loadRules();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupDescriptionController.dispose();
    _currencyController.dispose();
    _contributionAmountController.dispose();
    _roundSizeController.dispose();
    _customIntervalDaysController.dispose();
    _graceDaysController.dispose();
    _fineAmountController.dispose();
    _contributionAmountFocusNode
      ..removeListener(_handleRulesInputFocusChanged)
      ..dispose();
    _groupNameFocusNode
      ..removeListener(_handleRulesInputFocusChanged)
      ..dispose();
    _groupDescriptionFocusNode
      ..removeListener(_handleRulesInputFocusChanged)
      ..dispose();
    _currencyFocusNode
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
    super.dispose();
  }

  void _handleRulesInputFocusChanged() {
    final isFocused =
        _groupNameFocusNode.hasFocus ||
        _groupDescriptionFocusNode.hasFocus ||
        _currencyFocusNode.hasFocus ||
        _contributionAmountFocusNode.hasFocus ||
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
      final group = await repository.getGroup(
        widget.groupId,
        forceRefresh: true,
      );
      final rules = await repository.getGroupRules(widget.groupId);
      _groupNameController.text = group.name;
      _groupDescriptionController.text = group.description ?? '';
      _currencyController.text = group.currency;
      _visibility = group.visibility;
      if (rules != null) {
        _applyRules(rules);
      }
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
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
    _customIntervalDaysController.text =
        rules.customIntervalDays?.toString() ?? '';
    _graceDaysController.text = '${rules.graceDays}';
    _fineAmountController.text = '${rules.fineAmount}';
    _frequency = rules.frequency;
    _fineType = rules.fineType;
    _payoutMode = rules.payoutMode;
    _winnerSelectionTiming = rules.winnerSelectionTiming;
    _paymentMethods = rules.paymentMethods
        .where(
          (method) =>
              method == GroupPaymentMethodModel.telebirr ||
              method == GroupPaymentMethodModel.cashAck,
        )
        .toSet();
    if (_paymentMethods.isEmpty) {
      _paymentMethods = {GroupPaymentMethodModel.cashAck};
    }
  }

  bool _validateBasicsStep() {
    final groupName = _groupNameController.text.trim();
    final currency = _currencyController.text.trim().toUpperCase();
    final contributionAmount = int.tryParse(
      _contributionAmountController.text.trim(),
    );
    if (groupName.isEmpty) {
      setState(() => _errorMessage = 'Group name is required.');
      return false;
    }
    if (currency.length != 3) {
      setState(() => _errorMessage = 'Currency must be a 3-letter code.');
      return false;
    }
    if (contributionAmount == null || contributionAmount <= 0) {
      setState(
        () => _errorMessage = 'Contribution amount must be greater than 0.',
      );
      return false;
    }
    return true;
  }

  bool _validateTimingStep() {
    final roundSize = int.tryParse(_roundSizeController.text.trim()) ?? 2;
    final customIntervalDays = int.tryParse(
      _customIntervalDaysController.text.trim(),
    );
    if (_frequency == GroupRuleFrequencyModel.customInterval &&
        (customIntervalDays == null || customIntervalDays <= 0)) {
      setState(
        () => _errorMessage = 'Custom interval days must be greater than 0.',
      );
      return false;
    }
    if (roundSize < 2) {
      setState(() => _errorMessage = 'Round size must be at least 2.');
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
      setState(
        () => _errorMessage =
            'Fine amount must be greater than 0 for fixed fines.',
      );
      return false;
    }
    if (_paymentMethods.isEmpty) {
      setState(() => _errorMessage = 'Select at least one payment method.');
      return false;
    }
    if (_requiresAfterCollectionTiming(_payoutMode) &&
        _winnerSelectionTiming != WinnerSelectionTimingModel.afterCollection) {
      setState(() {
        _errorMessage =
            'Auction and decision payout modes require winner selection after collection.';
      });
      return false;
    }
    return true;
  }

  bool _requiresAfterCollectionTiming(GroupRulePayoutModeModel mode) {
    return mode == GroupRulePayoutModeModel.auction ||
        mode == GroupRulePayoutModeModel.decision;
  }

  Future<void> _saveRules() async {
    if (!_validateBasicsStep() ||
        !_validateTimingStep() ||
        !_validatePolicyStep()) {
      return;
    }

    final contributionAmount = int.parse(
      _contributionAmountController.text.trim(),
    );
    final groupName = _groupNameController.text.trim();
    final groupDescription = _groupDescriptionController.text.trim();
    final currency = _currencyController.text.trim().toUpperCase();
    final roundSize = int.parse(_roundSizeController.text.trim());
    final customIntervalDays = int.tryParse(
      _customIntervalDaysController.text.trim(),
    );
    final graceDays = int.parse(_graceDaysController.text.trim());
    final fineAmount = int.tryParse(_fineAmountController.text.trim()) ?? 0;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(groupsRepositoryProvider);
      await repository.updateGroup(
        widget.groupId,
        name: groupName,
        description: groupDescription.isEmpty ? '' : groupDescription,
        currency: currency,
        visibility: _visibility,
      );
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
              ? fineAmount
              : 0,
          payoutMode: _payoutMode,
          winnerSelectionTiming: _winnerSelectionTiming,
          paymentMethods: _paymentMethods.toList(growable: false),
          roundSize: roundSize,
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
      appBar: const KitAppBar(title: 'Group setup'),
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
        Expanded(
          child: ListView(
            children: [
              _buildSectionCard(
                context,
                title: 'Identity & access',
                child: _buildRulesStep(context, section: _RulesSection.basics),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSectionCard(
                context,
                title: 'Cycle timing',
                child: _buildRulesStep(context, section: _RulesSection.timing),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSectionCard(
                context,
                title: 'Payout & collection',
                child: _buildRulesStep(context, section: _RulesSection.policy),
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
              if (hideBottomCta) ...[
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: _isSubmitting ? null : _saveRules,
                  child: Text(_isSubmitting ? 'Saving...' : 'Save setup'),
                ),
              ],
            ],
          ),
        ),
        if (!hideBottomCta) ...[
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: _isSubmitting ? null : _saveRules,
            child: Text(_isSubmitting ? 'Saving...' : 'Save setup'),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    String? description,
    required Widget child,
  }) {
    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }

  Widget _buildRulesStep(
    BuildContext context, {
    required _RulesSection section,
  }) {
    final roundSize = int.tryParse(_roundSizeController.text.trim()) ?? 2;
    final reputationAsync = ref.watch(currentUserReputationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section == _RulesSection.basics) ...[
          if (_visibility == GroupVisibilityModel.public)
            reputationAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: KitBanner(
                  title: 'Checking access',
                  message: 'Loading...',
                  tone: KitBadgeTone.info,
                  icon: Icons.shield_outlined,
                ),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: KitBanner(
                  title: 'Access unavailable',
                  message: mapApiErrorToMessage(error),
                  tone: KitBadgeTone.warning,
                  icon: Icons.info_outline_rounded,
                ),
              ),
              data: (profile) => profile == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: KitBanner(
                        title: 'Public access',
                        message: hostRestrictionMessage(profile),
                        tone: profile.eligibility.hostTier == null
                            ? KitBadgeTone.warning
                            : KitBadgeTone.info,
                        icon: Icons.shield_outlined,
                      ),
                    ),
            ),
          AppTextField(
            controller: _groupNameController,
            focusNode: _groupNameFocusNode,
            label: 'Group name',
            hint: 'Family Equb',
            onChanged: (_) => setState(() => _errorMessage = null),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _groupDescriptionController,
            focusNode: _groupDescriptionFocusNode,
            label: 'Description',
            hint: 'What is this Equb for?',
            onChanged: (_) => setState(() => _errorMessage = null),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _currencyController,
            focusNode: _currencyFocusNode,
            label: 'Currency',
            hint: 'ETB',
            onChanged: (_) => setState(() => _errorMessage = null),
          ),
          const SizedBox(height: AppSpacing.md),
          KitDropdownField<GroupVisibilityModel>(
            value: _visibility,
            label: 'Visibility',
            items: const [
              DropdownMenuItem(
                value: GroupVisibilityModel.private,
                child: Text('Private'),
              ),
              DropdownMenuItem(
                value: GroupVisibilityModel.public,
                child: Text('Public'),
              ),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _visibility = value;
                _errorMessage = null;
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _contributionAmountController,
            focusNode: _contributionAmountFocusNode,
            label: 'Contribution amount',
            hint: '500',
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() => _errorMessage = null),
          ),
        ],
        if (section == _RulesSection.timing) ...[
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
                _errorMessage = null;
              });
            },
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
                if (_requiresAfterCollectionTiming(value)) {
                  _winnerSelectionTiming =
                      WinnerSelectionTimingModel.afterCollection;
                }
                _errorMessage = null;
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          KitDropdownField<WinnerSelectionTimingModel>(
            value: _winnerSelectionTiming,
            label: 'Winner selection timing',
            items: const [
              DropdownMenuItem(
                value: WinnerSelectionTimingModel.beforeCollection,
                child: Text('Before collection'),
              ),
              DropdownMenuItem(
                value: WinnerSelectionTimingModel.afterCollection,
                child: Text('After collection'),
              ),
            ],
            onChanged: _requiresAfterCollectionTiming(_payoutMode)
                ? null
                : (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _winnerSelectionTiming = value;
                      _errorMessage = null;
                    });
                  },
            supportText: _requiresAfterCollectionTiming(_payoutMode)
                ? 'Required for this payout mode.'
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _graceDaysController,
            focusNode: _graceDaysFocusNode,
            label: 'Grace days',
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
          Text(
            'Payment methods',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          _PaymentMethodTile(
            label: 'Telebirr',
            value: GroupPaymentMethodModel.telebirr,
            selectedMethods: _paymentMethods,
            onChanged: _togglePaymentMethod,
          ),
          _PaymentMethodTile(
            label: 'Manual',
            value: GroupPaymentMethodModel.cashAck,
            selectedMethods: _paymentMethods,
            onChanged: _togglePaymentMethod,
          ),
        ],
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

enum _RulesSection { basics, timing, policy }
