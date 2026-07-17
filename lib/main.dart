import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/child_profile_select_screen.dart';
import 'screens/child_shell.dart';
import 'screens/lesson_list_screen.dart';
import 'screens/lesson_player_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/quiz_result_screen.dart';
import 'screens/parent_shell.dart';
import 'screens/child_progress_detail_screen.dart';
import 'screens/screen_time_settings_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/offline_content_screen.dart';

void main() {
  runApp(const SafeZoneUltraApp());
}

class SafeZoneUltraApp extends StatelessWidget {
  const SafeZoneUltraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'SafeZone Ultra',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/profiles': (_) => const ChildProfileSelectScreen(),
          '/child': (_) => const ChildShell(),
          '/lessons': (_) => const LessonListScreen(),
          '/lesson-player': (_) => const LessonPlayerScreen(),
          '/quiz': (_) => const QuizScreen(),
          '/quiz-result': (_) => const QuizResultScreen(),
          '/parent': (_) => const ParentShell(),
          '/child-progress': (_) => const ChildProgressDetailScreen(),
          '/screen-time': (_) => const ScreenTimeSettingsScreen(),
          '/settings': (_) => const SettingsScreen(),
          '/offline': (_) => const OfflineContentScreen(),
        },
      ),
    );
  }
}
