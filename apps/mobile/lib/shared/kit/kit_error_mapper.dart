import '../utils/api_error_mapper.dart';

String mapFriendlyError(Object error) {
  return mapApiErrorToMessage(error);
}
