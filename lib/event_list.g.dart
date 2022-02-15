// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['name'],
  );
  return Event(
    name: json['name'] as String? ?? "Unnamed Event",
  )
    ..date =
        json['date'] == null ? null : DateTime.parse(json['date'] as String)
    ..location = json['location'] as String?;
}

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'name': instance.name,
      'date': instance.date?.toIso8601String(),
      'location': instance.location,
    };
