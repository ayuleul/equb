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
import '../../../shared/utils/api_error_mapper.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../group_detail_controller.dart';

class GroupSetupScreen extends ConsumerStatefulWidget {
  const GroupSetupScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupSetupScreen> createState() => _GroupSetupScreenState();
}

class _GroupSetupScreenState extends ConsumerState<GroupSetupScreen> {
  late final TextEditingController _contributionAmountController;
  late final TextEditingController _customIntervalDaysController;
  late final TextEditingController _graceDaysController;
  late final TextEditingController _fineAmountController;

  var _frequency = GroupRuleFrequencyModel.monthly;
  var _fineType = GroupRuleFineTypeModel.none;
  var _payoutMode = GroupRulePayoutModeModel.lottery;
  var _paymentMethods = <GroupPaymentMethodModel>{
    GroupPaymentMethodModel.cashAck,
  };
  var _requiresMemberVerification = false;
  var _strictCollection = false;

  var _isLoading = true;
  var _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _contributionAmountController = TextEditingController();
    _customIntervalDaysController = TextEditingController();
    _graceDaysController = TextEditingController(text: '0');
    _fineAmountController = TextEditingController(text: '0');
    _loadRules();
  }

  @override
  void dispose() {
    _contributionAmountController.dispose();
    _customIntervalDaysController.dispose();
    _graceDaysController.dispose();
    _fineAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadRules() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
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
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = mapApiErrorToMessage(error);
      });
    }
  }

  void _applyRules(GroupRulesModel rules) {
    _contributionAmountController.text = '${rules.contributionAmount}';
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
  }

  Future<void> _saveRules() async {
    final contributionAmount = int.tryParse(
      _contributionAmountController.text.trim(),
    );
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
          fineAmount: _fineType == GroupRuleFineTypeModel.fixedAmount
              ? (fineAmount ?? 0)
              : 0,
          payoutMode: _payoutMode,
          paymentMethods: _paymentMethods.toList(growable: false),
          requiresMemberVerification: _requiresMemberVerification,
          strictCollection: _strictCollection,
        ),
      );

      await ref
          .read(groupDetailControllerProvider)
          .refreshGroup(widget.groupId);
      if (!mounted) {
        return;
      }

      AppSnackbars.success(context, 'Group rules saved.');
      context.go(AppRoutePaths.groupDetail(widget.groupId));
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = mapApiErrorToMessage(error);
      });
      AppSnackbars.error(context, _errorMessage!);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KitScaffold(
      appBar: const KitAppBar(
        title: 'Group setup',
        subtitle: 'Step 1 of 1: Rules',
      ),
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const LoadingView(message: 'Loading rules...');
    }

    if (_errorMessage != null && _contributionAmountController.text.isEmpty) {
      return ErrorView(message: _errorMessage!, onRetry: _loadRules);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stepper(
            physics: const ClampingScrollPhysics(),
            currentStep: 0,
            controlsBuilder: (context, details) {
              return const SizedBox.shrink();
            },
            steps: [
              Step(
                isActive: true,
                title: const Text('Rules'),
                subtitle: const Text('Required before invites/cycles'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      controller: _contributionAmountController,
                      label: 'Contribution amount',
                      hint: '500',
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() => _errorMessage = null),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<GroupRuleFrequencyModel>(
                      initialValue: _frequency,
                      decoration: const InputDecoration(labelText: 'Frequency'),
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
                    if (_frequency ==
                        GroupRuleFrequencyModel.customInterval) ...[
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _customIntervalDaysController,
                        label: 'Custom interval (days)',
                        hint: '14',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() => _errorMessage = null),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _graceDaysController,
                      label: 'Grace days',
                      hint: '2',
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() => _errorMessage = null),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<GroupRuleFineTypeModel>(
                      initialValue: _fineType,
                      decoration: const InputDecoration(
                        labelText: 'Fine policy',
                      ),
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
                        label: 'Fine amount',
                        hint: '50',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() => _errorMessage = null),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<GroupRulePayoutModeModel>(
                      initialValue: _payoutMode,
                      decoration: const InputDecoration(
                        labelText: 'Payout mode',
                      ),
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
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Requires member verification'),
                      value: _requiresMemberVerification,
                      onChanged: (value) {
                        setState(() {
                          _requiresMemberVerification = value;
                        });
                      },
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Strict collection before payout'),
                      value: _strictCollection,
                      onChanged: (value) {
                        setState(() {
                          _strictCollection = value;
                        });
                      },
                    ),
                  ],
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
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isSubmitting ? null : _saveRules,
            icon: const Icon(Icons.check_circle_outline),
            label: Text(_isSubmitting ? 'Saving...' : 'Save rules'),
          ),
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
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      onChanged: (checked) => onChanged(value, checked ?? false),
    );
  }
}
