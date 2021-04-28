// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arkit_node_rotation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ARKitNodeRotationResult _$ARKitNodeRotationResultFromJson(
    Map<String, dynamic> json) {
  return ARKitNodeRotationResult(
    json['nodeName'] as String,
    json['parentNodeName'] as String,
    (json['rotation'] as num).toDouble(),
  );
}

Map<String, dynamic> _$ARKitNodeRotationResultToJson(
        ARKitNodeRotationResult instance) =>
    <String, dynamic>{
      'nodeName': instance.nodeName,
      'parentNodeName': instance.parentNodeName,
      'rotation': instance.rotation,
    };
