// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/component_type.dart';
import '../models/dashboard_state.dart';
import '../models/recipe_state.dart';
import '../models/reactor_state.dart';
import '../widgets/interactive_system_diagram.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showSystemDiagram = false;

  @override
  Widget build(BuildContext context) {
    return Consumer3<DashboardState, RecipeState, ReactorState>(
      builder: (context, dashboardState, recipeState, reactorState, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildViewToggle(),
                if (_showSystemDiagram)
                  _buildSystemDiagramView(reactorState)
                else
                  ...[
                    if (dashboardState.errorMessage != null)
                      _buildErrorMessage(context, dashboardState),
                    _buildRecipeSelector(context, dashboardState, recipeState),
                    SizedBox(height: 20),
                    _buildStatusIndicator(dashboardState),
                    SizedBox(height: 20),
                    _buildProgressIndicator(dashboardState),
                    SizedBox(height: 20),
                    _buildLoopStack(dashboardState),
                    SizedBox(height: 20),
                    _buildKeyParameters(dashboardState),
                    SizedBox(height: 20),
                    _buildControlButtons(context, dashboardState),
                    SizedBox(height: 20),
                    _buildRecentAlerts(dashboardState),
                  ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(_showSystemDiagram ? 'System Diagram' : 'Dashboard'),
        Switch(
          value: _showSystemDiagram,
          onChanged: (value) {
            setState(() {
              _showSystemDiagram = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSystemDiagramView(ReactorState reactorState) {
    return Container(
      height: 500, // Adjust as needed
      child: InteractiveSystemDiagram(
        reactorState: reactorState,
        onComponentTap: (ComponentType type) {
          // Handle component tap if needed
        },
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, DashboardState state) {
    return Card(
      color: Colors.red[100],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Expanded(child: Text(state.errorMessage!, style: TextStyle(color: Colors.red))),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: state.clearError,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeSelector(BuildContext context, DashboardState dashboardState, RecipeState recipeState) {
    return DropdownButton<String>(
      value: dashboardState.currentRecipe?.id,
      hint: Text('Select a recipe'),
      onChanged: (String? recipeId) {
        if (recipeId != null) {
          final selectedRecipe = recipeState.recipes.firstWhere((recipe) => recipe.id == recipeId);
          dashboardState.setCurrentRecipe(selectedRecipe);
        }
      },
      items: recipeState.recipes.map<DropdownMenuItem<String>>((recipe) {
        return DropdownMenuItem<String>(
          value: recipe.id,
          child: Text(recipe.name),
        );
      }).toList(),
    );
  }

  Widget _buildStatusIndicator(DashboardState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('ALD Process Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Current Step:'),
                Text(state.currentStep, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Elapsed Time:'),
                Text(state.elapsedTime, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Estimated Completion:'),
                Text(state.estimatedCompletion, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(DashboardState state) {
    double progress = state.totalSteps > 0 ? state.currentStepIndex / state.totalSteps : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Progress:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        LinearProgressIndicator(value: progress),
        SizedBox(height: 5),
        Text('Step ${state.currentStepIndex} of ${state.totalSteps}'),
      ],
    );
  }

  Widget _buildLoopStack(DashboardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Loop Stack:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        if (state.currentLoopStack.isEmpty)
          Text('No active loops')
        else
          Column(
            children: state.currentLoopStack.asMap().entries.map((entry) {
              int index = entry.key;
              LoopInfo loop = entry.value;
              return Text('Loop ${index + 1}: Iteration ${loop.currentIteration} of ${loop.totalIterations}');
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildKeyParameters(DashboardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Key Parameters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildParameterCard('Temperature', '${state.temperature.toStringAsFixed(1)}°C', Colors.red),
            _buildParameterCard('Pressure', '${state.pressure.toStringAsFixed(1)} mTorr', Colors.blue),
            _buildParameterCard('Gas Flow', '${state.gasFlow.toStringAsFixed(1)} sccm', Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildParameterCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 14)),
            SizedBox(height: 5),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context, DashboardState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: state.currentRecipe == null ? null : state.startProcess,
          child: Text('Start'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        ElevatedButton(
          onPressed: state.pauseProcess,
          child: Text('Pause'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        ),
        ElevatedButton(
          onPressed: state.stopProcess,
          child: Text('Stop'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
      ],
    );
  }

  Widget _buildRecentAlerts(DashboardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: state.recentAlerts.length,
          itemBuilder: (context, index) {
            final alert = state.recentAlerts[index];
            return Card(
              child: ListTile(
                leading: Icon(Icons.warning, color: Colors.yellow),
                title: Text(alert['message'] ?? ''),
                subtitle: Text(alert['time'] ?? ''),
              ),
            );
          },
        ),
      ],
    );
  }
}