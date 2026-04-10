import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'services/firebase_service.dart';
import 'services/auth_service.dart';
import 'services/settings_service.dart'; // Added
import 'utils/app_theme.dart';

void main() {
  runApp(const ETechApp());
}

class ETechApp extends StatelessWidget {
  const ETechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => SettingsService()), // Added
        ChangeNotifierProxyProvider<AuthService, FirebaseService>(
          create: (_) => FirebaseService(),
          update: (ctx, auth, previousFirebase) =>
              previousFirebase!..updateAuth(auth.token, auth.userId),
        ),
      ],
      child: Consumer<AuthService>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'ඊ-Tech Electricals',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: auth.isAuth ? const MainScreen() : const LoginScreen(),
        ),
      ),
    );
  }
}
