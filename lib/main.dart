import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/db_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBProvider.db.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alerts (OLX + Otomoto)',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF0F172A),
        colorScheme: ColorScheme.dark(primary: Color(0xFFFF6B00)),
        appBarTheme: AppBarTheme(backgroundColor: Color(0xFF0B1220))
      ),
      home: HomeScreen(),
    );
  }
}
