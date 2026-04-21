import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:godare/core/secure_storage.dart';
import 'package:godare/models/daily_item.dart';
import 'package:godare/pages/login_page.dart';
import 'package:godare/pages/my_home_page.dart';
import 'package:godare/providers/user_provider.dart';
import 'package:godare/services/daily_service.dart';
import 'package:godare/common/my_routers.dart';
import 'package:godare/values/colors_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');
  runApp(await _initializeApp());
}

Future<Widget> _initializeApp() async {
  final provider = UserProvider();

  final hasSession = await SecureStorage.hasToken();
  if (hasSession) {
    try {
      await provider.loadProfile();
      await provider.loadUnreadCount();
    } catch (_) {
      await SecureStorage.clearToken();
    }
  }

  return ChangeNotifierProvider.value(
    value: provider,
    child: MyApp(autorizado: provider.isLoggedIn),
  );
}

class MyApp extends StatelessWidget {
  final bool autorizado;

  const MyApp({super.key, required this.autorizado});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) => MyRouters.generateRoute(settings),
      debugShowCheckedModeBanner: false,
      title: 'VERDAD O RETO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        primaryColor: Colors.black,
        secondaryHeaderColor: Colors.black,
        useMaterial3: true,
      ),
      home: autorizado
          ? const HomeWithDaily()
          : const LoginPage(),
    );
  }
}

/// Wrapper de MyHomePage que comprueba el daily al entrar
class HomeWithDaily extends StatefulWidget {
  const HomeWithDaily({super.key});

  @override
  State<HomeWithDaily> createState() => _HomeWithDailyState();
}

class _HomeWithDailyState extends State<HomeWithDaily> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkDaily());
  }

  Future<void> _checkDaily() async {
    try {
      final daily = await DailyService.getMyDaily();
      if (!mounted) return;

      // solo si es de hoy y no fue transferido
      if (daily.generatedToday && daily.state != 'TRANSFERRED') {
        _showDailyDialog(daily);
      }
    } catch (_) {}
  }

  void _showDailyDialog(DailyItem daily) {
    const color = ColorsApp.basePink;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/icons/challenges.png',
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '¡RETO DIARIO!',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        // el contenido se oculta hasta abrirlo
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tienes un nuevo desafío diario.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ábrelo desde tu tablón de retos para ver los detalles.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Después'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamedAndRemoveUntil(
                ROUTE_HOME,
                    (route) => false,
                arguments: 2,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ver ahora'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const MyHomePage();
  }
}