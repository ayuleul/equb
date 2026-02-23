import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/models/group_rules_model.dart';

final groupRulesProvider = FutureProvider.family<GroupRulesModel?, String>((
  ref,
  groupId,
) async {
  final repository = ref.watch(groupsRepositoryProvider);
  return repository.getGroupRules(groupId);
});
