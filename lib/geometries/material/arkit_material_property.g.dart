// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arkit_material_property.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ARKitMaterialProperty _$ARKitMaterialPropertyFromJson(
    Map<String, dynamic> json) {
  return ARKitMaterialProperty(
    color: const ColorConverter().fromJson(json['color'] as int),
    image: json['image'] as String,
    url: json['url'] as String,
    isGif: json['isGif'] as bool,
    isVideo: json['isVideo'] as bool,
  );
}

Map<String, dynamic> _$ARKitMaterialPropertyToJson(
    ARKitMaterialProperty instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('color', const ColorConverter().toJson(instance.color));
  val['image'] = instance.image;
  val['url'] = instance.url;
  val['isGif'] = instance.isGif;
  val['isVideo'] = instance.isVideo;
  return val;
}
