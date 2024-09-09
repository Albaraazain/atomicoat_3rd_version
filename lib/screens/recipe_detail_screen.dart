import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../models/recipe_state.dart';
import 'dart:ui';

class TeslaColors {
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF000000);
  static const Color secondaryText = Color(0xFF757575);
  static const Color accent = Color(0xFF333333);
  static const Color divider = Color(0xFFE0E0E0);
}

class RecipeDetailScreen extends StatefulWidget {
  final String? recipeId;

  RecipeDetailScreen({this.recipeId});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> with TickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _substrateController;
  List<RecipeStep> _steps = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _substrateController = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _substrateController.dispose();
    _animationController.dispose();
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
          _substrateController.text = recipe.substrate ?? '';
          _steps = List.from(recipe.steps);
        }

        return Scaffold(
          backgroundColor: TeslaColors.background,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: TeslaColors.primaryText),
            title: Text(
              widget.recipeId == null ? 'Create Recipe' : 'Edit Recipe',
              style: TextStyle(color: TeslaColors.primaryText, fontWeight: FontWeight.w500),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.save, color: TeslaColors.accent),
                onPressed: () => _validateAndSaveRecipe(recipeState, recipe),
              ),
            ],
          ),
          body: Stack(
            children: [
              _buildBackgroundImage(),
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildRecipeNameInput(),
                      _buildSubstrateInput(),
                      _buildStepsHeader(),
                      Expanded(
                        child: _buildStepsList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecipeNameInput() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: TeslaColors.cardBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: TeslaColors.divider.withOpacity(0.5)),
            ),
            child: TextFormField(
              controller: _nameController,
              style: TextStyle(color: TeslaColors.primaryText, fontSize: 24, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Recipe Name',
                hintStyle: TextStyle(color: TeslaColors.secondaryText),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubstrateInput() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: TeslaColors.cardBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: TeslaColors.divider.withOpacity(0.5)),
            ),
            child: TextFormField(
              controller: _substrateController,
              style: TextStyle(color: TeslaColors.primaryText, fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Substrate',
                hintStyle: TextStyle(color: TeslaColors.secondaryText),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildBackgroundImage() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/subtle_pattern.png'),
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: TeslaColors.background.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildStepsHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Steps',
            style: TextStyle(
              color: TeslaColors.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          ElevatedButton(
            child: Text('Add Step'),
            style: ElevatedButton.styleFrom(
              foregroundColor: TeslaColors.cardBackground,
              backgroundColor: TeslaColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            onPressed: () => _showAddStepDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsList() {
    return ReorderableListView(
      padding: EdgeInsets.all(16),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final RecipeStep item = _steps.removeAt(oldIndex);
          _steps.insert(newIndex, item);
        });
      },
      children: _steps.asMap().entries.map((entry) {
        int index = entry.key;
        RecipeStep step = entry.value;
        return _buildStepCard(step, index);
      }).toList(),
    );
  }

  Widget _buildStepCard(RecipeStep step, int index) {
    return Card(
      key: ValueKey(step),
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: TeslaColors.cardBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: TeslaColors.divider.withOpacity(0.5)),
            ),
            child: ExpansionTile(
              title: Text(
                'Step ${index + 1}: ${_getStepTitle(step)}',
                style: TextStyle(
                  color: TeslaColors.primaryText,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStepEditor(step),
                      if (step.type == StepType.loop) _buildLoopSubSteps(step),
                    ],
                  ),
                ),
              ],
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _steps.removeAt(index);
                      });
                    },
                  ),
                  Icon(Icons.drag_handle, color: TeslaColors.secondaryText),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getStepTitle(RecipeStep step) {
    switch (step.type) {
      case StepType.loop:
        return 'Loop ${step.parameters['iterations']} times';
      case StepType.valve:
        return '${step.parameters['valveType'] == ValveType.valveA ? 'Valve A' : 'Valve B'} for ${step.parameters['duration']}s';
      case StepType.purge:
        return 'Purge for ${step.parameters['duration']}s';
      default:
        return 'Unknown Step';
    }
  }

  Widget _buildStepEditor(RecipeStep step) {
    switch (step.type) {
      case StepType.loop:
        return _buildNumberInput(
          label: 'Number of iterations',
          value: step.parameters['iterations'],
          onChanged: (value) {
            setState(() {
              step.parameters['iterations'] = value;
            });
          },
        );
      case StepType.valve:
        return Column(
          children: [
            _buildDropdown<ValveType>(
              label: 'Valve',
              value: step.parameters['valveType'],
              items: ValveType.values,
              onChanged: (value) {
                setState(() {
                  step.parameters['valveType'] = value;
                });
              },
            ),
            SizedBox(height: 16),
            _buildNumberInput(
              label: 'Duration (seconds)',
              value: step.parameters['duration'],
              onChanged: (value) {
                setState(() {
                  step.parameters['duration'] = value;
                });
              },
            ),
          ],
        );
      case StepType.purge:
        return _buildNumberInput(
          label: 'Duration (seconds)',
          value: step.parameters['duration'],
          onChanged: (value) {
            setState(() {
              step.parameters['duration'] = value;
            });
          },
        );
      default:
        return Text('Unknown Step Type', style: TextStyle(color: TeslaColors.primaryText));
    }
  }

  Widget _buildNumberInput({required String label, required int value, required Function(int) onChanged}) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: TextStyle(color: TeslaColors.secondaryText)),
        ),
        SizedBox(width: 16),
        Container(
          width: 120,
          child: TextFormField(
            initialValue: value.toString(),
            style: TextStyle(color: TeslaColors.primaryText),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: TeslaColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: TeslaColors.accent),
              ),
              filled: true,
              fillColor: TeslaColors.cardBackground.withOpacity(0.5),
            ),
            onChanged: (newValue) {
              onChanged(int.tryParse(newValue) ?? value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({required String label, required T value, required List<T> items, required Function(T?) onChanged}) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: TextStyle(color: TeslaColors.secondaryText)),
        ),
        SizedBox(width: 16),
        Container(
          width: 120,
          child: DropdownButtonFormField<T>(
            value: value,
            onChanged: onChanged,
            items: items.map((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  item.toString().split('.').last,
                  style: TextStyle(color: TeslaColors.primaryText),
                ),
              );
            }).toList(),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: TeslaColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: TeslaColors.accent),
              ),
              filled: true,
              fillColor: TeslaColors.cardBackground.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoopSubSteps(RecipeStep loopStep) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          'Loop Steps:',
          style: TextStyle(
            color: TeslaColors.primaryText,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        ...loopStep.subSteps!.asMap().entries.map((entry) {
          int index = entry.key;
          RecipeStep subStep = entry.value;
          return _buildSubStepCard(subStep, index, loopStep);
        }).toList(),
        SizedBox(height: 8),
        ElevatedButton(
          child: Text('Add Loop Step'),
          style: ElevatedButton.styleFrom(
            foregroundColor: TeslaColors.cardBackground,
            backgroundColor: TeslaColors.accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          onPressed: () => _showAddStepDialog(context, parentStep: loopStep),
        ),
      ],
    );
  }

  Widget _buildSubStepCard(RecipeStep step, int index, RecipeStep parentStep) {
    return Card(
        margin: EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: TeslaColors.background.withOpacity(0.5),
        elevation: 0,
        child: ListTile(
        title: Text(
        'Substep ${index + 1}: ${_getStepTitle(step)}',
    style: TextStyle(
    color: TeslaColors.primaryText,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    ),
    ),
    trailing: IconButton(
    icon: Icon(Icons.delete, color: Colors.red),
    onPressed: () {
    setState(() {
    parentStep.subSteps!.removeAt(index);
    });
    },
    ),
          onTap: () {
            // Show edit dialog for substep
            _showEditStepDialog(context, step, parentStep: parentStep);
          },
        ),
    );
  }

  void _validateAndSaveRecipe(RecipeState recipeState, Recipe? existingRecipe) {
    if (_nameController.text.isEmpty) {
      _showValidationError('Please enter a recipe name');
      return;
    }

    if (_substrateController.text.isEmpty) {
      _showValidationError('Please enter a substrate');
      return;
    }

    if (_steps.isEmpty) {
      _showValidationError('Please add at least one step to the recipe');
      return;
    }

    for (var step in _steps) {
      if (!_validateStep(step)) {
        return;
      }
    }

    final newRecipe = Recipe(
      id: existingRecipe?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      substrate: _substrateController.text,
      steps: _steps,
    );

    if (existingRecipe == null) {
      recipeState.addRecipe(newRecipe);
    } else {
      recipeState.updateRecipe(newRecipe);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recipe saved successfully'),
        backgroundColor: TeslaColors.accent,
      ),
    );
    Navigator.pop(context);
  }

  bool _validateStep(RecipeStep step) {
    switch (step.type) {
      case StepType.loop:
        if (step.parameters['iterations'] == null || step.parameters['iterations'] < 1) {
          _showValidationError('Please set a valid number of iterations for the loop step');
          return false;
        }
        if (step.subSteps == null || step.subSteps!.isEmpty) {
          _showValidationError('Please add at least one substep to the loop');
          return false;
        }
        for (var subStep in step.subSteps!) {
          if (!_validateStep(subStep)) {
            return false;
          }
        }
        break;
      case StepType.valve:
        if (step.parameters['valveType'] == null) {
          _showValidationError('Please select a valve type');
          return false;
        }
        if (step.parameters['duration'] == null || step.parameters['duration'] < 0) {
          _showValidationError('Please set a valid duration for the valve step');
          return false;
        }
        break;
      case StepType.purge:
        if (step.parameters['duration'] == null || step.parameters['duration'] < 0) {
          _showValidationError('Please set a valid duration for the purge step');
          return false;
        }
        break;
    }
    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }


  void _showAddStepDialog(BuildContext context, {RecipeStep? parentStep}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: TeslaColors.cardBackground.withOpacity(0.9),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('Add Step', style: TextStyle(fontWeight: FontWeight.bold, color: TeslaColors.primaryText)),
                ),
                if (parentStep == null)
                  ListTile(
                    leading: Icon(Icons.loop, color: TeslaColors.accent),
                    title: Text('Loop', style: TextStyle(color: TeslaColors.primaryText)),
                    onTap: () {
                      Navigator.pop(context);
                      _addStep(StepType.loop, parentStep?.subSteps ?? _steps);
                    },
                  ),
                ListTile(
                  leading: Icon(Icons.male, color: TeslaColors.accent),
                  title: Text('Valve', style: TextStyle(color: TeslaColors.primaryText)),
                  onTap: () {
                    Navigator.pop(context);
                    _addStep(StepType.valve, parentStep?.subSteps ?? _steps);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.air, color: TeslaColors.accent),
                  title: Text('Purge', style: TextStyle(color: TeslaColors.primaryText)),
                  onTap: () {
                    Navigator.pop(context);
                    _addStep(StepType.purge, parentStep?.subSteps ?? _steps);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditStepDialog(BuildContext context, RecipeStep step, {RecipeStep? parentStep}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Step', style: TextStyle(color: TeslaColors.primaryText)),
          content: SingleChildScrollView(
            child: _buildStepEditor(step),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: TeslaColors.accent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save', style: TextStyle(color: TeslaColors.accent)),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
          backgroundColor: TeslaColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        );
      },
    );
  }

  void _addStep(StepType type, List<RecipeStep> steps) {
    setState(() {
      switch (type) {
        case StepType.loop:
          steps.add(RecipeStep(
            type: StepType.loop,
            parameters: {'iterations': 1},
            subSteps: [],
          ));
          break;
        case StepType.valve:
          steps.add(RecipeStep(
            type: StepType.valve,
            parameters: {'valveType': ValveType.valveA, 'duration': 0},
          ));
          break;
        case StepType.purge:
          steps.add(RecipeStep(
            type: StepType.purge,
            parameters: {'duration': 0},
          ));
          break;
      }
    });
  }

  void _saveRecipe(RecipeState recipeState, Recipe? existingRecipe) {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a recipe name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newRecipe = Recipe(
      id: existingRecipe?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      steps: _steps, substrate: '',
    );

    if (existingRecipe == null) {
      recipeState.addRecipe(newRecipe);
    } else {
      recipeState.updateRecipe(newRecipe);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recipe saved successfully'),
        backgroundColor: TeslaColors.accent,
      ),
    );
    Navigator.pop(context);
  }
}

// Utility methods
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

String enumToString(Object o) => o.toString().split('.').last.capitalize();