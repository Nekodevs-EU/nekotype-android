// ignore_for_file: library_private_types_in_public_api

import 'package:animations/animations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness:
        Brightness.light, // Adjust icon brightness if needed
  ));

  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/lang',
        fallbackLocale: const Locale('en'),
        child: const MainApp()),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple, brightness: Brightness.dark),
      ),
      home: const HomeScreen(), // Use a separate widget for the UI
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String version = 'Vx.x.x';
  @override
  void initState() {
    super.initState();
    fetchVersion();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now we can safely use context here
    print('Current locale is: ${context.locale}');
  }

  Future<void> fetchVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  vibrateSelection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? status = prefs.getBool('haptics') ?? true;
    if (status == true) {
      final hasCustomVibrationsSupport =
          await Vibration.hasCustomVibrationsSupport();
      if (hasCustomVibrationsSupport != null && hasCustomVibrationsSupport) {
        Vibration.vibrate(duration: 50);
      } else {
        Vibration.vibrate();
        await Future.delayed(const Duration(milliseconds: 50));
        Vibration.vibrate();
      }
    }
  }

  vibrateError() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? status = prefs.getBool('haptics') ?? true;
    if (status == true) {
      final hasCustomVibrationsSupport =
          await Vibration.hasCustomVibrationsSupport();
      if (hasCustomVibrationsSupport != null && hasCustomVibrationsSupport) {
        Vibration.vibrate(duration: 200);
      } else {
        Vibration.vibrate();
        await Future.delayed(const Duration(milliseconds: 200));
        Vibration.vibrate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('app_name'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ), // Localization is now safe here!
        backgroundColor: const Color.fromARGB(82, 138, 100, 160),
        actions: [
          IconButton(
            onPressed: () {
              vibrateSelection();
              showModal(
                context: context,
                builder: (context) => FluidDialog(
                  alignmentCurve: Curves.easeInOutCubicEmphasized,
                  sizeDuration: const Duration(milliseconds: 300),
                  alignmentDuration: const Duration(milliseconds: 600),
                  transitionDuration: const Duration(milliseconds: 300),
                  reverseTransitionDuration: const Duration(milliseconds: 50),
                  transitionBuilder: (child, animation) => FadeScaleTransition(
                    animation: animation,
                    child: child,
                  ),
                  defaultDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  rootPage: FluidDialogPage(
                    alignment: Alignment.topRight,
                    builder: (context) => InfoDialog(version: version),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align text to the left
            children: [
              const SizedBox(height: 20.0),
              Text(tr('setup.title'),
                  style: TextStyle(fontSize: 23.0, color: Colors.purple[50])),
              const SizedBox(height: 15.0),
              Text(tr('setup.description'),
                  style: TextStyle(fontSize: 15.0, color: Colors.purple[100])),
              const SizedBox(height: 5.0),
              Divider(color: Colors.purple[100], thickness: 1.0),
              const SizedBox(height: 10.0),
              TextField(
                decoration: InputDecoration(
                  labelText: tr('auth.username'),
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: tr('auth.password'),
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    vibrateSelection();
                  },
                  icon: const Icon(Icons.login_rounded),
                  label: Text(tr('auth.authenticate')),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    vibrateSelection();
                  },
                  icon: const Icon(Icons.person_add_rounded),
                  label: Text(tr('auth.register')),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30.0),
              TextButton(
                onPressed: () {
                  vibrateSelection();
                },
                child: Text(
                  tr('auth.forgot_password'),
                  style: TextStyle(color: Colors.purple[100]),
                ),
              ),
              TextButton(
                onPressed: () {
                  vibrateSelection();
                },
                child: Text(
                  tr('system.privacy'),
                  style: TextStyle(color: Colors.purple[100]),
                ),
              ),
              TextButton(
                onPressed: () {
                  vibrateSelection();
                },
                child: Text(
                  tr('system.tos'),
                  style: TextStyle(color: Colors.purple[100]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoDialog extends StatelessWidget {
  final String version;
  const InfoDialog({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                tr('system.settings'),
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
              leading: const Icon(
                Icons.settings_rounded,
                color: Colors.grey,
              ),
              iconColor: Colors.grey,
              enabled: false,
            ),
            ListTile(
              title: Text(tr('system.about')),
              leading: const Icon(Icons.info_rounded),
              iconColor: Theme.of(context).colorScheme.onSurface,
              onTap: () => DialogNavigator.of(context).push(
                FluidDialogPage(
                  // This dialog is shown in the center of the screen.
                  alignment: Alignment.center,
                  // Using a custom decoration for this dialog.
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  builder: (context) => const AboutPage(),
                ),
              ),
            ),
            const Divider(),
            Text('v$version'),
            const Text('©NekoDevs'),
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 800,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => DialogNavigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            Text(
              tr('app_name'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              tr('app_description'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              tr('app_description_long'),
            )
          ],
        ),
      ),
    );
  }
}
