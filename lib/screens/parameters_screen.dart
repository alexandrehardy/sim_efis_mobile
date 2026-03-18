import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/logs.dart';
import 'package:sim_efis/screens/load_aircraft_limits.dart';
import 'package:sim_efis/settings.dart';
import 'package:sim_efis/snackbars.dart';
import 'package:sim_efis/text_style.dart';
import 'package:sim_efis/widgets/accept_dialog.dart';
import 'package:sim_efis/widgets/efis_dialog_page.dart';
import 'package:sim_efis/widgets/floating_button.dart';
import 'package:sim_efis/widgets/labelled_value.dart';
import 'package:sim_efis/widgets/numeric_text.dart';
import 'package:sim_efis/widgets/text_entry_dialog.dart';

class ParametersScreen extends StatefulWidget {
  const ParametersScreen({Key? key}) : super(key: key);

  @override
  State<ParametersScreen> createState() => _ParametersScreenState();
}

class _ParametersScreenState extends State<ParametersScreen> {
  AircraftLimits limits = InstrumentDataStream.instance.currentUI.limits;
  String aircraft = InstrumentDataStream.instance.currentUI.aircraftType;
  // Used to force a reload on state change
  int instance = 0;

  Future<bool> hasFilesToLoad() async {
    List<String> options = await Settings.loadableAircraftParams();
    return options.isNotEmpty;
  }

  Future<void> loadLimits(BuildContext context) async {
    NavigatorState navigator = Navigator.of(context);
    List<String> options = await Settings.loadableAircraftParams();
    if (options.isEmpty) {
      if (context.mounted) {
        showErrorSnackBar(
          context: context,
          message: 'No parameters available to load',
        );
      }
      return;
    }
    String? result = await navigator.push(
      MaterialPageRoute<String>(
        builder: (BuildContext context) => LoadAircraftLimitsScreen(
          aircraft: aircraft,
          options: options,
        ),
      ),
    );
    if (result != null) {
      String limitsString = await File(result).readAsString();
      setState(() {
        limits = AircraftLimits.decode(limitsString);
        InstrumentDataStream.instance.setAircraftLimits(limits);
        instance++;
      });
      if (aircraft.isEmpty) {
        if (context.mounted) {
          showSuccessSnackBar(
            context: context,
            message: 'Loaded parameters',
          );
        }
      } else {
        if (context.mounted) {
          showSuccessSnackBar(
            context: context,
            message: 'Loaded parameters for $aircraft',
          );
        }
      }
    }
  }

  Future<void> saveLimits(BuildContext context) async {
    String aircraftCode = aircraft.toUpperCase();
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      Directory aircraftDir = Directory('${appDocDir.path}/aircraft');
      await aircraftDir.create(recursive: true);
      if (aircraftCode == '') {
        String? newCode;
        if (context.mounted) {
          newCode = await showDialog(
            context: context,
            builder: (BuildContext context) => const TextEntryDialog(
              message:
                  'Please enter an aircraft type (the simulator did not provide one):',
            ),
          );
        }
        if (newCode == null) {
          return;
        } else {
          aircraftCode = newCode.toUpperCase();
        }
      }
      File limitsFile = File('${aircraftDir.path}/$aircraftCode.limits');
      bool fileExists = await limitsFile.exists();
      bool doSave = true;
      if (fileExists) {
        bool? result;
        if (context.mounted) {
          result = await showDialog(
            context: context,
            builder: (BuildContext context) => const AcceptDialog(
              message: 'Aircraft file already exists, replace it?',
            ),
          );
        }
        doSave = (result != null) && (result);
      }
      if (doSave) {
        await limitsFile.writeAsString(limits.encode(aircraftCode));
        if (context.mounted) {
          showSuccessSnackBar(
            context: context,
            message: 'Saved parameters for $aircraftCode',
          );
        }
        setState(() {
          instance++;
        });
      }
    } catch (e, s) {
      Logger.logError('Failed to save limits for $aircraftCode: $e', s);
      if (context.mounted) {
        showErrorSnackBar(
          context: context,
          message: 'Failed to save parameters for $aircraftCode',
        );
      }
    }
  }

  bool Function(double value) createOnChanged(
    AircraftLimits Function(double value) createLimit,
  ) {
    bool onChanged(double value) {
      limits = createLimit(value);
      InstrumentDataStream.instance.setAircraftLimits(limits);
      return true;
    }

    return onChanged;
  }

  @override
  Widget build(BuildContext context) {
    return EfisDialogPage(
      scrollable: false,
      child: Column(
        children: [
          LabelledValue(
            label: 'Aircraft:',
            value: aircraft,
          ),
          Text(
            'If parameters have been saved for a aircraft with this '
            'name, then they are automatically loaded when the simulator reports '
            'that this aircraft is in use.',
            style: EfisStyle.settingsTextStyle.copyWith(fontSize: 12.0),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  NumericTextWidget(
                    key: ValueKey('ENG$instance'),
                    label: 'ENGINES:',
                    onChanged: createOnChanged((value) =>
                        limits.copyWith(numberOfEngines: value.toInt())),
                    value: limits.numberOfEngines.toDouble(),
                    min: 0.0,
                    max: maxEngines.toDouble(),
                  ),
                  NumericTextWidget(
                    key: ValueKey('VR$instance'),
                    label: 'VR:',
                    onChanged:
                        createOnChanged((value) => limits.copyWith(vr: value)),
                    value: limits.vr,
                    min: 0.0,
                    max: 1000.0,
                  ),
                  NumericTextWidget(
                    key: ValueKey('VX$instance'),
                    label: 'VX:',
                    onChanged:
                        createOnChanged((value) => limits.copyWith(vx: value)),
                    value: limits.vx,
                    min: 0.0,
                    max: 1000.0,
                  ),
                  NumericTextWidget(
                    key: ValueKey('VY$instance'),
                    label: 'VY:',
                    onChanged:
                        createOnChanged((value) => limits.copyWith(vy: value)),
                    value: limits.vy,
                    min: 0.0,
                    max: 1000.0,
                  ),
                  NumericTextWidget(
                    key: ValueKey('VS$instance'),
                    label: 'VS:',
                    onChanged:
                        createOnChanged((value) => limits.copyWith(vs: value)),
                    value: limits.vs,
                    min: 0.0,
                    max: 1000.0,
                  ),
                  NumericTextWidget(
                    key: ValueKey('VSO$instance'),
                    label: 'VSO:',
                    onChanged:
                        createOnChanged((value) => limits.copyWith(vso: value)),
                    value: limits.vso,
                    min: 0.0,
                    max: 1000.0,
                  ),
                  NumericTextWidget(
                    key: ValueKey('VNO$instance'),
                    label: 'VNO:',
                    onChanged:
                        createOnChanged((value) => limits.copyWith(vno: value)),
                    value: limits.vno,
                    min: 0.0,
                    max: 1000.0,
                  ),
                  NumericTextWidget(
                    key: ValueKey('VFE$instance'),
                    label: 'VFE:',
                    onChanged:
                        createOnChanged((value) => limits.copyWith(vfe: value)),
                    value: limits.vfe,
                    min: 0.0,
                    max: 1000.0,
                  ),
                  NumericTextWidget(
                    key: ValueKey('VNE$instance'),
                    label: 'VNE:',
                    onChanged:
                        createOnChanged((value) => limits.copyWith(vne: value)),
                    value: limits.vne,
                    min: 0.0,
                    max: 1000.0,
                  ),
                  NumericTextWidget(
                    key: ValueKey('FUEL$instance'),
                    label: 'FUEL:',
                    onChanged: createOnChanged(
                        (value) => limits.copyWith(maxFuel: value)),
                    value: limits.maxFuel,
                    min: 0.0,
                    max: 1000.0,
                  ),
                  NumericTextWidget(
                    key: ValueKey('MINRPM$instance'),
                    label: 'MINRPM:',
                    onChanged: createOnChanged(
                        (value) => limits.copyWith(minRpm: value)),
                    value: limits.minRpm,
                    min: 0.0,
                    max: 10000.0,
                  ),
                  NumericTextWidget(
                    key: ValueKey('MAXRPM$instance'),
                    label: 'MAXRPM:',
                    onChanged: createOnChanged(
                        (value) => limits.copyWith(maxRpm: value)),
                    value: limits.maxRpm,
                    min: 0.0,
                    max: 10000.0,
                  ),
                  NumericTextWidget(
                    key: ValueKey('OILTMIN$instance'),
                    label: 'OIL TEMP MIN:',
                    onChanged: createOnChanged(
                        (value) => limits.copyWith(oilTempMin: value)),
                    value: limits.oilTempMin,
                    min: 0.0,
                    max: 1000.0,
                  ),
                  NumericTextWidget(
                    key: ValueKey('OILTMAX$instance'),
                    label: 'OIL TEMP MAX:',
                    onChanged: createOnChanged(
                        (value) => limits.copyWith(oilTempMax: value)),
                    value: limits.oilTempMax,
                    min: 0.0,
                    max: 1000.0,
                  ),
                  NumericTextWidget(
                    key: ValueKey('CHTMIN$instance'),
                    label: 'CHT MIN:',
                    onChanged: createOnChanged(
                        (value) => limits.copyWith(cylinderTempMin: value)),
                    value: limits.cylinderTempMin,
                    min: 0.0,
                    max: 1000.0,
                  ),
                  NumericTextWidget(
                    key: ValueKey('CHTMAX$instance'),
                    label: 'CHT MAX:',
                    onChanged: createOnChanged(
                        (value) => limits.copyWith(cylinderTempMax: value)),
                    value: limits.cylinderTempMax,
                    min: 0.0,
                    max: 1000.0,
                  ),
                  NumericTextWidget(
                    key: ValueKey('EGTMIN$instance'),
                    label: 'EGT MIN:',
                    onChanged: createOnChanged(
                        (value) => limits.copyWith(exhaustGasTempMin: value)),
                    value: limits.exhaustGasTempMin,
                    min: 0.0,
                    max: 1000.0,
                  ),
                  NumericTextWidget(
                    key: ValueKey('EGTMAX$instance'),
                    label: 'EGT MAX:',
                    onChanged: createOnChanged(
                        (value) => limits.copyWith(exhaustGasTempMax: value)),
                    value: limits.exhaustGasTempMax,
                    min: 0.0,
                    max: 1000.0,
                  ),
                  NumericTextWidget(
                    key: ValueKey('OILPMIN$instance'),
                    label: 'OIL PRESSURE MIN:',
                    onChanged: createOnChanged(
                        (value) => limits.copyWith(oilPressureMin: value)),
                    value: limits.oilPressureMin,
                    min: 0.0,
                    max: 1000.0,
                  ),
                  NumericTextWidget(
                    key: ValueKey('OILPMAX$instance'),
                    label: 'OIL PRESSURE MAX:',
                    onChanged: createOnChanged(
                        (value) => limits.copyWith(oilPressureMax: value)),
                    value: limits.oilPressureMax,
                    min: 0.0,
                    max: 1000.0,
                  ),
                  NumericTextWidget(
                    key: ValueKey('MPMIN$instance'),
                    label: 'MANIFOLD PRESSURE MIN:',
                    onChanged: createOnChanged(
                        (value) => limits.copyWith(manifoldPressureMin: value)),
                    value: limits.manifoldPressureMin,
                    min: 10.0,
                    max: 50.0,
                  ),
                  NumericTextWidget(
                    key: ValueKey('MPMAX$instance'),
                    label: 'MANIFOLD PRESSURE MAX:',
                    onChanged: createOnChanged(
                        (value) => limits.copyWith(manifoldPressureMax: value)),
                    value: limits.manifoldPressureMax,
                    min: 10.0,
                    max: 50.0,
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingButton(
                label: const Text(
                  'SAVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                onPressed: () {
                  saveLimits(context);
                },
              ),
              FutureBuilder(
                key: ValueKey('Load$instance'),
                future: hasFilesToLoad(),
                initialData: false,
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) =>
                    (snapshot.requireData)
                        ? FloatingButton(
                            label: const Text(
                              'LOAD',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            onPressed: () {
                              loadLimits(context);
                            },
                          )
                        : Container(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
