// lib/screens/recipe_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_state.dart';
import '../models/recipe.dart';
import 'recipe_detail_screen.dart';

class RecipeManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeState>(
      builder: (context, recipeState, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Recipe Management'),
            actions: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailScreen(),
                  ),
                ),
              ),
            ],
          ),
          body: recipeState.recipes.isEmpty
              ? Center(child: Text('No recipes available. Add a new recipe to get started.'))
              : ListView.builder(
            itemCount: recipeState.recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipeState.recipes[index];
              return ListTile(
                title: Text(recipe.name),
                subtitle: Text('${recipe.steps.length} steps'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => recipeState.deleteRecipe(recipe.id),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(recipeId: recipe.id),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}