import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/chamado_provider.dart';
import 'screens/dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  runApp(const SOSCidadeApp());
}

class SOSCidadeApp extends StatefulWidget {
  const SOSCidadeApp({super.key});

  @override
  State<SOSCidadeApp> createState() => _SOSCidadeAppState();
}

class _SOSCidadeAppState extends State<SOSCidadeApp> {
  bool _isDark = false;

  void _toggleTheme() {
    setState(() => _isDark = !_isDark);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChamadoProvider(),
      child: MaterialApp(
        title: 'SOS Cidade',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [
          Locale('pt', 'BR'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: DashboardScreen(
          onToggleTheme: _toggleTheme,
          isDark: _isDark,
        ),
      ),
    );
  }
}
