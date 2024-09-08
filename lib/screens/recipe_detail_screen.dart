// lib/screens/recipe_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../models/recipe_state.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String? recipeId;

  RecipeDetailScreen({this.recipeId});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late TextEditingController _nameController;
  List<RecipeStep> _steps = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeState>(
      builder: (context, recipeState, child) {
        Recipe? recipe;
        if (widget.recipeId != null) {
          recipe = recipeState.recipes.firstWhere((r) => r.id == widget.recipeId);
          _nameController.text = recipe.name;
          _steps = List.from(recipe.steps);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.recipeId == null ? 'Create Recipe' : 'Edit Recipe'),
            actions: [
              IconButton(
                icon: Icon(Icons.save),
                onPressed: () => _saveRecipe(recipeState, recipe),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Recipe Name'),
                ),
                SizedBox(height: 20),
                Text('Steps:', style: Theme.of(context).textTheme.titleLarge),
                ..._buildStepsList(_steps),
                ElevatedButton(
                  onPressed: () => _showAddStepDialog(context, _steps),
                  child: Text('Add Step'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildStepsList(List<RecipeStep> steps) {
    return steps.asMap().entries.map((entry) {
      int index = entry.key;
      RecipeStep step = entry.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(_getStepDescription(step)),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  steps.removeAt(index);
                });
              },
            ),
          ),
          if (step.type == StepType.loop)
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._buildStepsList(step.subSteps ?? []),
                  ElevatedButton(
                    onPressed: () => _showAddStepDialog(context, step.subSteps ?? []),
                    child: Text('Add Step to Loop'),
                  ),
                ],
              ),
            ),
        ],
      );
    }).toList();
  }

  String _getStepDescription(RecipeStep step) {
    switch (step.type) {
      case StepType.loop:
        return 'Loop (${step.parameters['iterations']} iterations)';
      case StepType.valve:
        return '${step.parameters['valveType'] == ValveType.valveA ? 'Valve A' : 'Valve B'} open for ${step.parameters['duration']} seconds';
      case StepType.purge:
        return 'Purge for ${step.parameters['duration']} seconds';
      default:
        return 'Unknown Step';
    }
  }

  void _showAddStepDialog(BuildContext context, List<RecipeStep> steps) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Add Step'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _addLoopStep(steps);
              },
              child: Text('Add Loop'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _addValveStep(steps);
              },
              child: Text('Add Valve Step'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _addPurgeStep(steps);
              },
              child: Text('Add Purge Step'),
            ),
          ],
        );
      },
    );
  }

  void _addLoopStep(List<RecipeStep> steps) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String iterations = '';
        return AlertDialog(
          title: Text('Add Loop'),
          content: TextField(
            decoration: InputDecoration(labelText: 'Number of iterations'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              iterations = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                setState(() {
                  steps.add(RecipeStep(
                    type: StepType.loop,
                    parameters: {'iterations': int.parse(iterations)},
                    subSteps: [],
                  ));
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addValveStep(List<RecipeStep> steps) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        ValveType? selectedValve;
        String duration = '';
        return AlertDialog(
          title: Text('Add Valve Step'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ValveType>(
                decoration: InputDecoration(labelText: 'Valve'),
                value: selectedValve,
                onChanged: (ValveType? newValue) {
                  selectedValve = newValue;
                },
                items: ValveType.values.map((ValveType valve) {
                  return DropdownMenuItem<ValveType>(
                    value: valve,
                    child: Text(valve == ValveType.valveA ? 'Valve A' : 'Valve B'),
                  );
                }).toList(),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Duration (seconds)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  duration = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (selectedValve != null) {
                  setState(() {
                    steps.add(RecipeStep(
                      type: StepType.valve,
                      parameters: {
                        'valveType': selectedValve,
                        'duration': int.parse(duration),
                      },
                    ));
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _addPurgeStep(List<RecipeStep> steps) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String duration = '';
        return AlertDialog(
          title: Text('Add Purge Step'),
          content: TextField(
            decoration: InputDecoration(labelText: 'Duration (seconds)'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              duration = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                setState(() {
                  steps.add(RecipeStep(
                    type: StepType.purge,
                    parameters: {'duration': int.parse(duration)},
                  ));
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveRecipe(RecipeState recipeState, Recipe? existingRecipe) {
    final newRecipe = Recipe(
      id: existingRecipe?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      steps: _steps,
    );

    if (existingRecipe == null) {
      recipeState.addRecipe(newRecipe);
    } else {
      recipeState.updateRecipe(newRecipe);
    }
    Navigator.pop(context);
  }
}