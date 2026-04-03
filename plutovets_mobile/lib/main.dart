import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'core/router.dart';
import 'core/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Add Firebase initialization when ready
  // await Firebase.initializeApp();
  
  // Suppression temporaire du BLoC pour éviter les erreurs de compilation
  runApp(const PlutoVetsApp());
}

class PlutoVetsApp extends StatelessWidget {
  const PlutoVetsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
