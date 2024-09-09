import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'recipe.dart';

class RecipeState extends ChangeNotifier {
  List<Recipe> _recipes = [];
  Recipe? _selectedRecipe;
  Recipe? _activeRecipe;
  static const String _storageKey = 'ald_recipes';
  static const String _activeRecipeKey = 'active_recipe';
  String? _errorMessage;

  List<Recipe> get recipes => _recipes;
  Recipe? get selectedRecipe => _selectedRecipe;
  Recipe? get activeRecipe => _activeRecipe;
  String? get errorMessage => _errorMessage;

  RecipeState() {
    _loadRecipes();
    _loadActiveRecipe();
  }

  Future<void> _loadRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? recipesJson = prefs.getString(_storageKey);
      if (recipesJson != null) {
        final List<dynamic> decodedRecipes = jsonDecode(recipesJson);
        _recipes = decodedRecipes.map((json) => Recipe.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to load recipes: $e';
      notifyListeners();
    }
  }

  Future<void> _saveRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedRecipes = jsonEncode(_recipes.map((recipe) => recipe.toJson()).toList());
      await prefs.setString(_storageKey, encodedRecipes);
    } catch (e) {
      _errorMessage = 'Failed to save recipes: $e';
      notifyListeners();
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    _recipes.add(recipe);
    await _saveRecipes();
    notifyListeners();
  }

  Future<void> updateRecipe(Recipe updatedRecipe) async {
    final index = _recipes.indexWhere((recipe) => recipe.id == updatedRecipe.id);
    if (index != -1) {
      _recipes[index] = updatedRecipe;
      if (_selectedRecipe?.id == updatedRecipe.id) {
        _selectedRecipe = updatedRecipe;
      }
      if (_activeRecipe?.id == updatedRecipe.id) {
        _activeRecipe = updatedRecipe;
      }
      await _saveRecipes();
      notifyListeners();
    }
  }

  Future<void> deleteRecipe(String id) async {
    _recipes.removeWhere((recipe) => recipe.id == id);
    if (_selectedRecipe?.id == id) {
      _selectedRecipe = null;
    }
    if (_activeRecipe?.id == id) {
      _activeRecipe = null;
    }
    await _saveRecipes();
    notifyListeners();
  }

  void selectRecipe(String id) {
    _selectedRecipe = _recipes.firstWhere((recipe) => recipe.id == id);
    notifyListeners();
  }

  Future<void> setActiveRecipe(Recipe recipe) async {
    _activeRecipe = recipe;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeRecipeKey, jsonEncode(recipe.toJson()));
    notifyListeners();
  }

  Future<void> _loadActiveRecipe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? activeRecipeJson = prefs.getString(_activeRecipeKey);
      if (activeRecipeJson != null) {
        _activeRecipe = Recipe.fromJson(jsonDecode(activeRecipeJson));
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to load active recipe: $e';
      notifyListeners();
    }
  }

  void clearActiveRecipe() {
    _activeRecipe = null;
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_activeRecipeKey);
    });
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}