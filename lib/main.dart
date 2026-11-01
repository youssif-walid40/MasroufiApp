import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'screens/main_screen.dart';
import 'providers/expense_provider.dart';
import 'data/firestore_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Links the app to the Firebase project using the generated keys in firebase_options.dart
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FireStoreHelper().seedDefaultCategories();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ExpenseProvider(),
      child: MaterialApp(
        title: 'Masroufi App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1FAD72)),
        ),
        home: const MainScreen(),
      ),
    );
  }
}
