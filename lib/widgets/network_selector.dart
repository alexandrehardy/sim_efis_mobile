import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sim_efis/network.dart';
import 'package:sim_efis/settings.dart';
import 'package:sim_efis/widgets/radio_group.dart';

class AllInterfaces extends NetworkInterface {
  AllInterfaces();
  @override
  String get name => 'All';
  @override
  int get index => 0;
  @override
  List<InternetAddress> get addresses => const [];
}

class NetworkSelector extends StatelessWidget {
  const NetworkSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getOrderedNetworks(),
      initialData: const [],
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        List<NetworkInterface> interfaces =
            List.from(snapshot.requireData).cast<NetworkInterface>();
        interfaces.add(AllInterfaces());
        String selected = Settings.listenInterface;
        Map<String, NetworkInterface> interfaceMap = {};
        for (NetworkInterface interface in interfaces) {
          interfaceMap[interface.name] = interface;
        }

        Widget buildNetworkWidget(String interfaceName) {
          if (!interfaceMap.containsKey(interfaceName)) {
            return Container();
          }

          if (interfaceName == 'All') {
            return Text(interfaceName);
          }
          NetworkInterface interface = interfaceMap[interfaceName]!;
          return Row(
            children: [
              Icon(
                  isWifi(interface)
                      ? Icons.wifi
                      : (isMobile(interface))
                          ? Icons.three_g_mobiledata
                          : CupertinoIcons.question_circle,
                  color: Colors.white),
              const SizedBox(width: 10.0),
              Text('${interface.addresses.first.address} (${interface.name})'),
            ],
          );
        }

        return RadioGroup(
          title: 'NETWORK ADDRESSES:',
          settings: interfaces.map((e) => e.name).toList(),
          selected: selected,
          onChanged: (value) {
            Settings.listenInterface = value;
            if (value == 'All') {
              Settings.listenOn = null;
            } else {
              Settings.listenOn = interfaceMap[value]!.addresses.first.address;
            }
          },
          builder: buildNetworkWidget,
        );
      },
    );
  }
}
