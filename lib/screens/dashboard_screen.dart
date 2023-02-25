import 'package:flutter/material.dart';

import '../widgets/dashboard_screen_gauge_view.dart';
import '../widgets/dashboard_screen_scada.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key, required this.switchDashboardPage})
      : super(key: key);
  final Function switchDashboardPage;
  static const temperatureConfig = {
    'units': '°C',
    'minValue': 0.0,
    'maxValue': 100.0,
    'range1Value': 25.0,
    'range2Value': 55.0
  };
  static const humidityConfig = {
    'units': '%',
    'minValue': 0.0,
    'maxValue': 100.0,
    'range1Value': 25.0,
    'range2Value': 55.0
  };
  static const flowConfig = {
    'units': 'lpm',
    'minValue': 0.0,
    'maxValue': 40.0,
    'range1Value': 15.0,
    'range2Value': 25.0
  };
  static const powerConfig = {
    'units': 'KW',
    'minValue': 0.0,
    'maxValue': 100.0,
    'range1Value': 15.0,
    'range2Value': 65.0
  };
  static const irradianceConfig = {
    'units': 'w/m²',
    'minValue': 0.0,
    'maxValue': 2000.0,
    'range1Value': 400.0,
    'range2Value': 900.0
  };

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  var _scadaView = true;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    _scadaView = orientation == Orientation.landscape;
    return LayoutBuilder(
        builder: (builder, cons) => SizedBox(
              width: cons.maxWidth,
              height: cons.maxHeight,
              child: _scadaView
                  ? DashboardScreenScada(cons: cons)
                  : DashboardScreenGaugeView(
                      switchDashboardPage: widget.switchDashboardPage,
                      cons: cons),
            ));
  }
}