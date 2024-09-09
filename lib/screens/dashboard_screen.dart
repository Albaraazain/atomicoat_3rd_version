import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../models/dashboard_state.dart';
import '../models/recipe.dart';
import '../models/recipe_state.dart';
import '../models/reactor_state.dart';
import '../styles/theme.dart';
import '../widgets/process_timeline.dart';
import '../widgets/realtime_chart.dart';

// Custom Widgets

class AnimatedParameterTile extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const AnimatedParameterTile({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  _AnimatedParameterTileState createState() => _AnimatedParameterTileState();
}

class _AnimatedParameterTileState extends State<AnimatedParameterTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.scale(
            scale: 0.8 + (_animation.value * 0.2),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, color: widget.color, size: 24),
                  SizedBox(height: 8),
                  Text(widget.title, style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color)),
                  SizedBox(height: 4),
                  Text(widget.value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData activeIcon;
  final IconData inactiveIcon;

  const CustomSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.activeIcon,
    required this.inactiveIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 60,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: value ? Theme.of(context).primaryColor : Colors.grey[300],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: value ? 30 : 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  value ? activeIcon : inactiveIcon,
                  size: 20,
                  color: value ? Theme.of(context).primaryColor : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FadeInSlideTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final double delay;

  const FadeInSlideTransition({
    Key? key,
    required this.child,
    required this.animation,
    this.delay = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final delayedAnimation = CurvedAnimation(
      parent: animation,
      curve: Interval(delay, 1.0, curve: Curves.easeOut),
    );

    return AnimatedBuilder(
      animation: delayedAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: delayedAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - delayedAnimation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// Main Dashboard Screen

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Container(
        color: Colors.white70, // Set the background to pure white
        child: SafeArea(
          child: _buildBody(context),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('ALD Dashboard', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300)),
      backgroundColor: Colors.white.withOpacity(0.8),
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: Colors.black),
          onPressed: () {
            // TODO: Implement notifications view
          },
        ),
        IconButton(
          icon: Icon(Icons.settings_outlined, color: Colors.black),
          onPressed: () {
            // TODO: Implement settings
          },
        ),
      ],
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    Color? backgroundColor,
    String? emoji,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),  // Larger rounded corners
      ),
      elevation: 1,  // Minimal elevation
      color: backgroundColor ?? Colors.white,  // Custom background colors
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji or Icon
            emoji != null
                ? Text(
              emoji,
              style: TextStyle(fontSize: 24),
            )
                : Icon(
              icon,
              color: color,
              size: 28,  // Slightly smaller icon
            ),
            SizedBox(height: 16),

            // Title with custom styling
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: ALDColors.textLight,
              ),
            ),

            SizedBox(height: 8),

            // Value with bold style
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,  // Bold value text
                color: ALDColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildBody(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(24),
      children: [
        FadeInSlideTransition(
          animation: _animationController,
          child: _buildHeaderSection(context),
        ),
        SizedBox(height: 24),
        FadeInSlideTransition(
          animation: _animationController,
          delay: 0.2,
          child: _buildMainDashboard(context),
        ),
        SizedBox(height: 24),
        FadeInSlideTransition(
          animation: _animationController,
          delay: 0.4,
          child: _buildChartSection(context),
        ),
        SizedBox(height: 24),
        FadeInSlideTransition(
          animation: _animationController,
          delay: 0.6,
          child: _buildBottomSection(context),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRecipeSelector(context),
        SizedBox(height: 24),
        _buildQuickActions(context),
      ],
    );
  }

  Widget _buildRecipeSelector(BuildContext context) {
    return Consumer2<DashboardState, RecipeState>(
      builder: (context, dashboardState, recipeState, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: DropdownButton<Recipe>(
            hint: Text('Choose Recipe', style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).primaryColor),
            underline: SizedBox(),
            onChanged: (Recipe? newValue) {
              if (newValue != null) {
                dashboardState.setCurrentRecipe(newValue);
              }
            },
            items: recipeState.recipes.map<DropdownMenuItem<Recipe>>((Recipe recipe) {
              return DropdownMenuItem<Recipe>(
                value: recipe,
                child: Text(recipe.name, style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildQuickActionButton(
          context,
          icon: Icons.stop_circle_outlined,
          label: 'Emergency Stop',
          onPressed: () {
            // TODO: Implement emergency stop
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Emergency Stop Activated')),
            );
          },
          color: Color(0xFFFF3B30),
        ),
        _buildQuickActionButton(
          context,
          icon: Icons.assessment_outlined,
          label: 'Generate Report',
          onPressed: () {
            // TODO: Implement report generation
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Generating Report...')),
            );
          },
          color: Theme.of(context).primaryColor,
        ),
        _buildQuickActionButton(
          context,
          icon: Icons.build_outlined,
          label: 'Calibrate',
          onPressed: () {
            // TODO: Implement calibration process
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Starting Calibration...')),
            );
          },
          color: Color(0xFFFF9500),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withOpacity(0.1),
            shape: CircleBorder(),
            padding: EdgeInsets.all(16),
            elevation: 0,
          ),
          child: Icon(icon, color: color),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
      ],
    );
  }

  Widget _buildMainDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusOverview(context),
        SizedBox(height: 24),
        _buildParameterGrid(context),
        SizedBox(height: 24),
        _buildControlPanel(context),
        SizedBox(height: 24),
        _buildSystemHealthIndicator(context),
      ],
    );
  }

  Widget _buildStatusOverview(BuildContext context) {
    return Consumer<DashboardState>(
      builder: (context, dashboardState, child) {
        return Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: Theme.of(context).textTheme.titleLarge?.color)),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusItem(context, 'Current Step', dashboardState.currentStep),
                  _buildStatusItem(context, 'Elapsed Time', dashboardState.elapsedTime),
                  _buildStatusItem(context, 'Est. Completion', dashboardState.estimatedCompletion),
                ],
              ),
              SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: dashboardState.progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color)),
      ],
    );
  }

  Widget _buildParameterGrid(BuildContext context) {
    return Consumer<ReactorState>(
      builder: (context, reactorState, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

            return GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 3,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return _buildParameterCard(
                      'Temperature',
                      '${reactorState.chamberTemperature}°C',
                      Icons.thermostat_outlined,
                    );
                  case 1:
                    return _buildParameterCard(
                      'Pressure',
                      '${reactorState.chamberPressure} mTorr',
                      Icons.compress_outlined,
                    );
                  case 2:
                    return _buildParameterCard(
                      'Gas Flow',
                      '${reactorState.n2FlowRate} sccm',
                      Icons.air_outlined,
                    );
                  default:
                    return Container();
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildParameterCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 24),
            SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: Theme.of(context).textTheme.titleMedium),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildControlPanel(BuildContext context) {
    return Consumer<DashboardState>(
      builder: (context, dashboardState, child) {
        return Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Control Panel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: Theme.of(context).textTheme.titleLarge?.color)),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildControlButton(context, 'Start', Icons.play_arrow, dashboardState.canStart ? () => dashboardState.startProcess() : null),
                  _buildControlButton(context, 'Pause', Icons.pause, dashboardState.canPause ? () => dashboardState.pauseProcess() : null),
                  _buildControlButton(context, 'Stop', Icons.stop, dashboardState.canStop ? () => dashboardState.stopProcess() : null),
                  _buildControlButton(context, 'Reset', Icons.refresh, dashboardState.canReset ? () => dashboardState.resetProcess() : null),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButton(BuildContext context, String label, IconData icon, VoidCallback? onPressed) {
    final isEnabled = onPressed != null;
    final color = isEnabled ? Theme.of(context).primaryColor : Colors.grey;

    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            foregroundColor: color, backgroundColor: color.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.all(16),
            elevation: 0,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14, color: isEnabled ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).textTheme.bodySmall?.color)),
      ],
    );
  }

  Widget _buildSystemHealthIndicator(BuildContext context) {
    return Consumer<ReactorState>(
      builder: (context, reactorState, child) {
        return Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('System Health', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: Theme.of(context).textTheme.titleLarge?.color)),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHealthIndicator(context, 'Overall', reactorState.systemHealth),
                  _buildHealthIndicator(context, 'Chamber', reactorState.componentHealth['chamber'] ?? 0),
                  _buildHealthIndicator(context, 'Pump', reactorState.componentHealth['pump'] ?? 0),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHealthIndicator(BuildContext context, String label, double health) {
    final Color indicatorColor = health > 0.7 ? Color(0xFF34C759) : (health > 0.4 ? Color(0xFFFF9500) : Color(0xFFFF3B30));

    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: health,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
                strokeWidth: 8,
              ),
              Center(
                child: Text(
                  '${(health * 100).toInt()}%',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: indicatorColor),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Text(label, style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color)),
      ],
    );
  }

  Widget _buildChartSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Process Data', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: Theme.of(context).textTheme.titleLarge?.color)),
          SizedBox(height: 24),
          _buildRealtimeChart(context),
          SizedBox(height: 24),
          _buildProcessTimeline(context),
        ],
      ),
    );
  }

  Widget _buildRealtimeChart(BuildContext context) {
    return Consumer<ReactorState>(
      builder: (context, reactorState, child) {
        return Container(
          height: 300,
          child: RealtimeChart(
            temperatureData: reactorState.temperatureHistory,
            pressureData: reactorState.pressureHistory,
            gasFlowData: reactorState.gasFlowHistory,
          ),
        );
      },
    );
  }

  Widget _buildProcessTimeline(BuildContext context) {
    return Consumer<DashboardState>(
      builder: (context, dashboardState, child) {
        return Container(
          height: 100,
          child: ProcessTimeline(
            steps: dashboardState.processSteps.map((step) => ProcessStep(
              name: step.name,
              status: step.status,
              duration: step.duration,
            )).toList(),
            currentStepIndex: dashboardState.currentStepIndex,
            onStepTap: (index) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Step Details: ${dashboardState.processSteps[index].name}'),
                  content: Text('Detailed information for step ${index + 1}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Alerts & Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: Theme.of(context).textTheme.titleLarge?.color)),
          SizedBox(height: 24),
          _buildAlertList(context),
        ],
      ),
    );
  }

  Widget _buildAlertList(BuildContext context) {
    return Consumer<DashboardState>(
      builder: (context, dashboardState, child) {
        return Column(
          children: [
            ...dashboardState.recentAlerts.map((alert) => _buildAlertItem(context, alert)).toList(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: Text('Alert History')),
                    body: ListView.builder(
                      itemCount: dashboardState.allAlerts.length,
                      itemBuilder: (context, index) {
                        final alert = dashboardState.allAlerts[index];
                        return _buildAlertItem(context, alert);
                      },
                    ),
                  ),
                ));
              },
              child: Text('View All Alerts'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlertItem(BuildContext context, Map<String, dynamic> alert) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Color(0xFFFF9500)),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert['message']?.toString() ?? '',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color)),
                SizedBox(height: 4),
                Text(alert['time']?.toString() ?? '',
                    style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}