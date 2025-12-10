import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'screens/task_list_screen.dart';
import 'widgets/app_shell.dart';
import 'screens/feed_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage and notifications
  await StorageService.init();
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider()..loadTasks(),
      child: MaterialApp(
        title: 'Space - Tasks',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: AppShell(
          pages: const [
            TaskListScreen(),
            FeedScreen(),
            SearchScreen(),
            SettingsScreen(),
          ],
        ),
      ),
    );
  }
}
