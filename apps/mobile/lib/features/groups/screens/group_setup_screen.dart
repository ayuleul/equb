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
  var _isSubmittingRules = false;
  var _isGeneratingInvite = false;
  String? _verifyingMemberId;
  String? _latestInviteCode;
  String? _latestInviteJoinUrl;
  String? _errorMessage;

  var _currentStep = 0;
  var _rulesSaved = false;

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
        _rulesSaved = true;
        _currentStep = 1;
      }
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
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
        });
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

  Future<void> _saveRulesAndContinue() async {
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
        ),
      );

      await ref.read(groupDetailControllerProvider).refreshAll(widget.groupId);

      if (!mounted) {
        return;
      }

      setState(() {
        _rulesSaved = true;
        _currentStep = 1;
      });

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
        subtitle: _currentStep == 0
            ? 'Step 1 of 2: Rules'
            : 'Step 2 of 2: Invite & Verify',
      ),
      child: _buildBody(context, groupAsync, membersAsync),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncValue<GroupModel> groupAsync,
    AsyncValue<List<MemberModel>> membersAsync,
  ) {
    if (_isLoading) {
      return const LoadingView(message: 'Loading setup...');
    }

    if (_errorMessage != null && _contributionAmountController.text.isEmpty) {
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
          child: Stepper(
            physics: const ClampingScrollPhysics(),
            currentStep: _currentStep,
            onStepTapped: (index) {
              if (index == 0 || _rulesSaved) {
                setState(() {
                  _currentStep = index;
                  _errorMessage = null;
                });
              }
            },
            controlsBuilder: (_, _) => const SizedBox.shrink(),
            steps: [
              Step(
                isActive: _currentStep == 0,
                state: _rulesSaved ? StepState.complete : StepState.indexed,
                title: const Text('Rules'),
                subtitle: const Text('Required first'),
                content: _buildRulesStep(context),
              ),
              Step(
                isActive: _currentStep == 1,
                state: _rulesSaved ? StepState.indexed : StepState.disabled,
                title: const Text('Invite & Verify'),
                subtitle: const Text('Prepare eligible members'),
                content: _buildInviteVerifyStep(
                  context,
                  groupAsync,
                  membersAsync,
                  participatingMembers,
                  verifiedMembers,
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
        if (_currentStep == 0)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isSubmittingRules ? null : _saveRulesAndContinue,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(_isSubmittingRules ? 'Saving...' : 'Save rules'),
            ),
          ),
        if (_currentStep == 1)
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

  Widget _buildRulesStep(BuildContext context) {
    return Column(
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
        if (_frequency == GroupRuleFrequencyModel.customInterval) ...[
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
          decoration: const InputDecoration(labelText: 'Fine policy'),
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
          decoration: const InputDecoration(labelText: 'Payout mode'),
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
    );
  }

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
    final missingCount = eligibleCount >= 2 ? 0 : 2 - eligibleCount;

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
          message: missingCount == 0
              ? 'Eligible members: $eligibleCount (ready to start cycles).'
              : requiresVerification
              ? 'Need $missingCount more verified member(s). Eligible now: $eligibleCount.'
              : 'Need $missingCount more joined member(s). Eligible now: $eligibleCount.',
          tone: missingCount == 0 ? KitBadgeTone.success : KitBadgeTone.warning,
          icon: missingCount == 0
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

    return Row(
      children: [
        KitAvatar(name: member.displayName, size: KitAvatarSize.sm),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.displayName,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (member.verifiedAt != null)
                Text(
                  'Verified ${member.verifiedAt!.toLocal()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        StatusPill.fromLabel(roleLabel),
        const SizedBox(width: AppSpacing.xs),
        StatusPill.fromLabel(memberStatusLabel(member.status)),
        if (canVerify) ...[
          const SizedBox(width: AppSpacing.xs),
          TextButton(
            onPressed: isVerifying ? null : onVerify,
            child: Text(isVerifying ? 'Verifying...' : 'Verify'),
          ),
        ],
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
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      onChanged: (checked) => onChanged(value, checked ?? false),
    );
  }
}
