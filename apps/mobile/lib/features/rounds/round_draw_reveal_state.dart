import 'package:flutter_riverpod/flutter_riverpod.dart';

final roundJustStartedProvider = StateProvider.family<bool, String>((
  ref,
  groupId,
) {
  return false;
});
