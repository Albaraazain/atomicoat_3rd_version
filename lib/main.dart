// lib/main.dart
import 'package:ald_machine_app/screens/user_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/dashboard_state.dart';
import 'models/recipe_state.dart';
import 'models/reactor_state.dart';
import 'models/user.dart';
import 'screens/dashboard_screen.dart';
import 'models/user_state.dart';
import 'screens/recipe_management_screen.dart';
import 'screens/log_view_screen.dart';
import 'screens/alarm_management_screen.dart';
import 'screens/maintenance_screen.dart';
import 'screens/reactor_control_screen.dart';
import 'screens/login_screen.dart';
import 'styles/theme.dart';
import 'widgets/role_based_access.dart';
import 'screens/user_profile_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DashboardState()),
        ChangeNotifierProvider(create: (context) => RecipeState()),
        ChangeNotifierProvider(create: (context) => ReactorState()),
        ChangeNotifierProvider(create: (context) => UserState()),
      ],
      child: ALDMachineApp(),
    ),
  );
}

class ALDMachineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALD Machine Control',
      theme: aldTheme(),
      home: Consumer<UserState>(
        builder: (context, userState, child) {
          return userState.currentUser == null ? LoginScreen() : HomePage();
        },
      ),
    );
  }
}


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    RecipeManagementScreen(),
    LogViewScreen(),
    AlarmManagementScreen(),
    MaintenanceScreen(),
    ReactorControlScreen(),
    RoleBasedAccess(
      allowedRoles: [UserRole.admin],
      child: UserManagementScreen(),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final isAdmin = userState.currentUser?.role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: Text('ALD Machine Control'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Alarms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Maintenance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science),
            label: 'Reactor',
          ),
          if (isAdmin)
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Users',
            ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final userState = Provider.of<UserState>(context, listen: false);
                userState.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
