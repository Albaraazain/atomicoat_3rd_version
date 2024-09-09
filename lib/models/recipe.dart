import 'package:json_annotation/json_annotation.dart';

part 'recipe.g.dart';

@JsonSerializable(explicitToJson: true)
class Recipe {
  String id;
  String name;
  List<RecipeStep> steps;

  Recipe({required this.id, required this.name, required this.steps, required String substrate});

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

  get substrate => null;
  Map<String, dynamic> toJson() => _$RecipeToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RecipeStep {
  StepType type;
  Map<String, dynamic> parameters;
  List<RecipeStep>? subSteps;

  RecipeStep({required this.type, required this.parameters, this.subSteps});

  factory RecipeStep.fromJson(Map<String, dynamic> json) => _$RecipeStepFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeStepToJson(this);
}

enum StepType {
  loop,
  valve,
  purge,
}

enum ValveType {
  valveA,
  valveB,
}