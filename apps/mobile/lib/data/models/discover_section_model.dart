import 'public_group_model.dart';

class DiscoverSectionModel {
  const DiscoverSectionModel({
    required this.key,
    required this.title,
    required this.items,
  });

  final String key;
  final String title;
  final List<PublicGroupModel> items;

  factory DiscoverSectionModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (item) =>
                    PublicGroupModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(growable: false)
        : const <PublicGroupModel>[];

    return DiscoverSectionModel(
      key: json['key'] as String? ?? '',
      title: json['title'] as String? ?? '',
      items: items,
    );
  }
}
