// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipe _$RecipeFromJson(Map<String, dynamic> json) => Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      steps: (json['steps'] as List<dynamic>)
          .map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'steps': instance.steps.map((e) => e.toJson()).toList(),
    };

RecipeStep _$RecipeStepFromJson(Map<String, dynamic> json) => RecipeStep(
      type: $enumDecode(_$StepTypeEnumMap, json['type']),
      parameters: json['parameters'] as Map<String, dynamic>,
      subSteps: (json['subSteps'] as List<dynamic>?)
          ?.map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RecipeStepToJson(RecipeStep instance) =>
    <String, dynamic>{
      'type': _$StepTypeEnumMap[instance.type]!,
      'parameters': instance.parameters,
      'subSteps': instance.subSteps?.map((e) => e.toJson()).toList(),
    };

const _$StepTypeEnumMap = {
  StepType.loop: 'loop',
  StepType.valve: 'valve',
  StepType.purge: 'purge',
};
