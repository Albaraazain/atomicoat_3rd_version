import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_state.dart';
import '../models/recipe_state.dart';
import '../models/reactor_state.dart';
import '../models/component_type.dart';
import '../widgets/real_time_chart.dart';
import '../widgets/interactive_system_diagram.dart';
import '../widgets/component_control_panel.dart';
import '../widgets/force_landscape.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showDiagram = false;

  @override
  Widget build(BuildContext context) {
    return _showDiagram
        ? _buildLandscapeSystemDiagramView()
        : _buildPortraitDashboardView();
  }

  Widget _buildLandscapeSystemDiagramView() {
    return ForceLandscape(
      child: Scaffold(
        body: Consumer2<ReactorState, DashboardState>(
          builder: (context, reactorState, dashboardState, child) {
            return Stack(
              children: [
                InteractiveSystemDiagram(
                  reactorState: reactorState,
                  onTapComponent: (ComponentType type) {
                    _showComponentControlPanel(context, type, reactorState);
                  },
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: _buildMiniStatusCard(dashboardState),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: _buildControlPanel(dashboardState),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _showDiagram = false;
                      });
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPortraitDashboardView() {
    return Scaffold(
      appBar: AppBar(
        title: Text('ALD Machine Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.fullscreen),
            onPressed: () {
              setState(() {
                _showDiagram = true;
              });
            },
          ),
        ],
      ),
      body: Consumer3<DashboardState, RecipeState, ReactorState>(
        builder: (context, dashboardState, recipeState, reactorState, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRecipeSelector(dashboardState, recipeState),
                  SizedBox(height: 20),
                  _buildStatusIndicator(dashboardState),
                  SizedBox(height: 20),
                  _buildKeyParameters(reactorState),
                  SizedBox(height: 20),
                  _buildControlButtons(dashboardState),
                  SizedBox(height: 20),
                  _buildRealtimeChart(reactorState),
                  SizedBox(height: 20),
                  _buildRecentAlerts(dashboardState),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniStatusCard(DashboardState state) {
    return Card(
      color: Colors.white.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Step: ${state.currentStep}'),
            Text('Elapsed: ${state.elapsedTime}'),
            Text('ETA: ${state.estimatedCompletion}'),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel(DashboardState state) {
    return Card(
      color: Colors.white.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: state.startProcess,
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
        ),
      ),
    );
  }

  void _showComponentControlPanel(BuildContext context, ComponentType type, ReactorState reactorState) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: ComponentControlPanel(type: type, reactorState: reactorState),
          ),
        );
      },
    );
  }

  Widget _buildRecipeSelector(DashboardState dashboardState, RecipeState recipeState) {
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

  Widget _buildKeyParameters(ReactorState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Key Parameters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildParameterCard('Temperature', '${state.chamberTemperature.toStringAsFixed(1)}°C', Colors.red),
            _buildParameterCard('Pressure', '${state.chamberPressure.toStringAsFixed(1)} mTorr', Colors.blue),
            _buildParameterCard('Gas Flow', '${state.n2FlowRate.toStringAsFixed(1)} sccm', Colors.green),
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

  Widget _buildControlButtons(DashboardState state) {
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

  Widget _buildRealtimeChart(ReactorState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Real-time Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: RealTimeChart(reactorState: state),
            ),
          ],
        ),
      ),
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