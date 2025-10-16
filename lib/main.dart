import 'package:flutter/material.dart';
import 'pages/years_semesters_page.dart';
import 'utils/theme.dart';
import 'utils/storage.dart';

void main() async {
  // Ensure Flutter is initialized before using async operations
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage before running the app
  await StorageManager().init();
  
  runApp(const GPACalculatorApp());
}

class GPACalculatorApp extends StatelessWidget {
  const GPACalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniGPA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkBlueTheme,
      home: const YearsSemestersPage(),
    );
  }
}