import 'package:flutter/material.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/settings.dart';

class ConnectionStatusWidget extends StatefulWidget {
  const ConnectionStatusWidget({Key? key}) : super(key: key);

  @override
  State<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    animationController!.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UiState>(
      initialData: UiStateController.state,
      stream: UiStateController.stream,
      builder: (BuildContext context, snapshot) {
        if (snapshot.requireData.connected) {
          return FadeTransition(
            opacity: animationController!,
            child: const Icon(
              Icons.play_arrow,
              color: Colors.green,
              size: 24,
            ),
          );
        } else {
          return GestureDetector(
            onTap: () => Settings.reconnect(),
            child: const Icon(
              Icons.stop,
              color: Colors.red,
              size: 24,
            ),
          );
        }
      },
    );
  }
}
