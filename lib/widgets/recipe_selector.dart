import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../styles/theme.dart';

class RecipeSelector extends StatefulWidget {
  final Recipe? currentRecipe;
  final List<Recipe> recipes;
  final Function(Recipe) onRecipeSelected;

  const RecipeSelector({
    Key? key,
    required this.currentRecipe,
    required this.recipes,
    required this.onRecipeSelected,
  }) : super(key: key);

  @override
  _RecipeSelectorState createState() => _RecipeSelectorState();
}

class _RecipeSelectorState extends State<RecipeSelector> {
  late TextEditingController _searchController;
  List<Recipe> _filteredRecipes = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredRecipes = widget.recipes;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterRecipes(String query) {
    setState(() {
      _filteredRecipes = widget.recipes
          .where((recipe) => recipe.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Recipe', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search recipes',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterRecipes,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: widget.currentRecipe?.id,
              decoration: InputDecoration(
                hintText: 'Select a recipe',
                filled: true,
                fillColor: ALDColors.background,
              ),
              onChanged: (String? recipeId) {
                if (recipeId != null) {
                  final selectedRecipe = widget.recipes.firstWhere((recipe) => recipe.id == recipeId);
                  widget.onRecipeSelected(selectedRecipe);
                }
              },
              items: _filteredRecipes.map<DropdownMenuItem<String>>((Recipe recipe) {
                return DropdownMenuItem<String>(
                  value: recipe.id,
                  child: Text(recipe.name),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}