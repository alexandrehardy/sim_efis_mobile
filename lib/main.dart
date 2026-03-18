import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sim_efis/colors.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/logbook/logbook.dart';
import 'package:sim_efis/lifecycle.dart';
import 'package:sim_efis/logs.dart';
import 'package:sim_efis/network.dart';
import 'package:sim_efis/screens/main_screen.dart';
import 'package:sim_efis/settings.dart';
import 'package:sim_efis/text_style.dart';
import 'package:sim_efis/textures.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NetworkPorts.setupDefaultPorts();
  NetworkPorts.setupPreferredPorts();
  if (kReleaseMode) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      Logger.log('Error building UI widget: ${details.exception}');
      Logger.log('Error building UI widget trace: ${details.stack}');
      FlutterError.presentError(details);
      return Container();
    };
    FlutterError.onError = (FlutterErrorDetails details) {
      Logger.log('Error: ${details.exception}');
      Logger.log('Error trace: ${details.stack}');
      FlutterError.presentError(details);
    };
  }
  // Start a background load of images
  Textures.loadTextures(onComplete: () {
    // Trigger a state delivery to redraw all instruments
    InstrumentDataStream.instance.forceStateDelivery();
  });
  // Always keep the screen on when in the app
  WakelockPlus.enable();
  getSubnetString().then(
    (value) {
      Settings.connectTo = value;
    },
  );
  getLocalNetwork().then(
    (value) {
      if (value != null) {
        Settings.listenInterface = value.name;
        Settings.listenOn = value.addresses.first.address;
      }
    },
  );
  Logbook.instance.loadLogbook();
  runApp(const SimEfisApp());
}

class SimEfisApp extends StatefulWidget {
  const SimEfisApp({Key? key}) : super(key: key);

  @override
  State<SimEfisApp> createState() => _SimEfisAppState();
}

class _SimEfisAppState extends State<SimEfisApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //debugShowCheckedModeBanner: false,
      //showPerformanceOverlay: true,
      title: 'Sim EFIS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        canvasColor: EfisColors.background,
        scaffoldBackgroundColor: EfisColors.background,
        unselectedWidgetColor: Colors.white,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          titleTextStyle: EfisStyle.appbarTextStyle,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}
