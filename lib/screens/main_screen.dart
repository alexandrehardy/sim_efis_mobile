import 'package:flutter/material.dart';
import 'package:sim_efis/colors.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/instruments/digital_clock/digital_clock.dart';
import 'package:sim_efis/screens/efis_help_screen.dart';
import 'package:sim_efis/screens/settings.dart';
import 'package:sim_efis/settings.dart';
import 'package:sim_efis/text_style.dart';
import 'package:sim_efis/widgets/connection_status_widget.dart';
import 'package:sim_efis/widgets/efis_page.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  Widget buildPages({
    required Size size,
    required EfisPage first,
    required EfisPage firstOverlay,
    required EfisPage second,
    required EfisPage secondOverlay,
  }) {
    Widget firstPage = EfisPageWidget(
      function: first,
      overlay: firstOverlay,
      page: SelectedPage.first,
    );
    Widget secondPage = EfisPageWidget(
      function: second,
      overlay: secondOverlay,
      page: SelectedPage.second,
    );
    if (first != EfisPage.none) {
      firstPage = Expanded(child: firstPage);
    }
    if (second != EfisPage.none) {
      secondPage = Expanded(child: secondPage);
    }
    if (size.width > size.height) {
      return Row(
        children: [
          firstPage,
          secondPage,
        ],
      );
    } else {
      return Column(
        children: [
          firstPage,
          secondPage,
        ],
      );
    }
  }

  Widget body(Size screenSize) => Center(
        child: StreamBuilder<UiState>(
          initialData: UiStateController.state,
          stream: UiStateController.stream,
          builder: (BuildContext context, snapshot) {
            return Stack(
              children: [
                buildPages(
                  size: screenSize,
                  first: snapshot.requireData.firstPage,
                  firstOverlay: snapshot.requireData.overlayFirstPage,
                  second: snapshot.requireData.secondPage,
                  secondOverlay: snapshot.requireData.overlaySecondPage,
                ),
                if (screenSize.width > screenSize.height)
                  Positioned(
                    child: GestureDetector(
                      onTap: () {
                        UiStateController.setFirstPage(EfisPage.selector);
                      },
                      child: Container(
                        color: Colors.black45,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.view_sidebar, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                if (screenSize.width <= screenSize.height)
                  Positioned(
                    right: 0.0,
                    child: GestureDetector(
                      onTap: () {
                        UiStateController.setFirstPage(EfisPage.selector);
                      },
                      child: Container(
                        color: Colors.black45,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.view_sidebar, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                if (screenSize.width > screenSize.height)
                  Positioned(
                    right: 0.0,
                    child: GestureDetector(
                      onTap: () {
                        UiStateController.setSecondPage(EfisPage.selector);
                      },
                      child: Container(
                        color: Colors.black45,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.view_sidebar, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                if (screenSize.width <= screenSize.height)
                  Positioned(
                    bottom: 0.0,
                    right: 0.0,
                    child: GestureDetector(
                      onTap: () {
                        UiStateController.setSecondPage(EfisPage.selector);
                      },
                      child: Container(
                        color: Colors.black45,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.view_sidebar, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    Settings.landscapeMode = (screenSize.width > screenSize.height);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('SIM EFIS'),
            if (screenSize.width > 500.0)
              const Expanded(
                child: Center(
                  child: DigitalClock(),
                ),
              ),
            if (screenSize.width <= 500.0)
              Expanded(
                  child: Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Container(
                    color: Colors.black,
                    child: const ConnectionStatusWidget(),
                  ),
                ),
              )),
          ],
        ),
        backgroundColor: EfisColors.background,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2),
            child: RawMaterialButton(
              constraints: const BoxConstraints(minHeight: 40, minWidth: 40),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const EfisHelpScreen(),
                  ),
                );
              },
              elevation: 10.0,
              fillColor:
                  Theme.of(context).floatingActionButtonTheme.foregroundColor ??
                      Colors.blueAccent,
              shape: const CircleBorder(),
              child: const Text(
                '?',
                style: EfisStyle.settingsTextStyle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2),
            child: RawMaterialButton(
              constraints: const BoxConstraints(minHeight: 40, minWidth: 40),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const SettingsScreen(),
                  ),
                );
              },
              elevation: 10.0,
              fillColor:
                  Theme.of(context).floatingActionButtonTheme.foregroundColor ??
                      Colors.blueAccent,
              shape: const CircleBorder(),
              child: const Icon(Icons.settings, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(child: body(screenSize)),
    );
  }
}
