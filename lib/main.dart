import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/lead_provider.dart';
import 'services/storage_service.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/leads_list_screen.dart';
import 'screens/kanban_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = await StorageService.init();
  final supabaseService = SupabaseService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LeadProvider(
            storageService: storageService,
            supabaseService: supabaseService,
          ),
        ),
      ],
      child: const FalconCrmApp(),
    ),
  );
}

class FalconCrmApp extends StatefulWidget {
  const FalconCrmApp({super.key});

  @override
  State<FalconCrmApp> createState() => _FalconCrmAppState();
}

class _FalconCrmAppState extends State<FalconCrmApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FalconCRM | Falconate Leads & Relationship Engine',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: MainNavigationShell(
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const MainNavigationShell({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _setIndex(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        onNavigateToLeads: () => _setIndex(1),
        onNavigateToKanban: () => _setIndex(2),
      ),
      const LeadsListScreen(),
      const KanbanScreen(),
      const SettingsScreen(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;

        if (isWide) {
          // Web / Desktop Dashboard Layout with NavigationRail
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _setIndex,
                  extended: constraints.maxWidth >= 1050,
                  backgroundColor: widget.isDarkMode
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF1F5F9),
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.rocket_launch, color: Colors.white, size: 20),
                        ),
                        if (constraints.maxWidth >= 1050) ...[
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FalconCRM',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'falconate.com',
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: IconButton(
                          icon: Icon(
                            widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          ),
                          tooltip: 'Toggle Theme',
                          onPressed: widget.onToggleTheme,
                        ),
                      ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people_outline),
                      selectedIcon: Icon(Icons.people),
                      label: Text('Leads Directory'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.view_kanban_outlined),
                      selectedIcon: Icon(Icons.view_kanban),
                      label: Text('Pipeline'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Settings & Sync'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: screens[_currentIndex]),
              ],
            ),
          );
        }

        // Mobile Layout (Android / Compact) with Custom Elevated Navigation Bar
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: widget.isDarkMode ? AppTheme.darkSurface : Colors.white,
              border: Border(
                top: BorderSide(
                  color: widget.isDarkMode ? AppTheme.darkBorder : AppTheme.lightBorder,
                  width: 1,
                ),
              ),
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 64,
              indicatorColor: const Color(0xFF3B82F6).withValues(alpha: 0.18),
              selectedIndex: _currentIndex,
              onDestinationSelected: _setIndex,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined, size: 20),
                  selectedIcon: Icon(Icons.dashboard_rounded, color: Color(0xFF3B82F6), size: 21),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline_rounded, size: 20),
                  selectedIcon: Icon(Icons.people_rounded, color: Color(0xFF3B82F6), size: 21),
                  label: 'Leads',
                ),
                NavigationDestination(
                  icon: Icon(Icons.view_kanban_outlined, size: 20),
                  selectedIcon: Icon(Icons.view_kanban_rounded, color: Color(0xFF3B82F6), size: 21),
                  label: 'Pipeline',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined, size: 20),
                  selectedIcon: Icon(Icons.settings_rounded, color: Color(0xFF3B82F6), size: 21),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
