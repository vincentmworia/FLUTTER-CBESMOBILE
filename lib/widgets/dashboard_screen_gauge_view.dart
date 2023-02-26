import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/mqtt.dart';
import '../screens/dashboard_screen.dart';
import '../screens/home_screen.dart';
import './linear_gauge.dart';
import './radial_gauge_sf.dart';

class DashboardScreenGaugeView extends StatelessWidget {
  const DashboardScreenGaugeView(
      {Key? key,
      required this.switchDashboardPage,
      required this.cons,
      required this.openPage})
      : super(key: key);
  final Function switchDashboardPage;
  final Function openPage;
  final BoxConstraints cons;

  static final bdRadius = BorderRadius.circular(10);

  Widget _gaugeView(List listData, double width) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: listData
          .map(
            (e) => Expanded(
                child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: e['title'].toString().contains('Tank') ||
                      e['title'].toString().contains('A.') ||
                      e['title'].toString().contains('Irradiance')
                  ? LinearGauge(
                      title: e['title'],
                      data: e['data'] == '_._' ? '0.0' : e['data']!,
                      min: e['minValue'],
                      max: e['maxValue'],
                      units: e['units'],
                      gaugeWidth: width * 0.15,
                    )
                  : SyncfusionRadialGauge(
                      title: e['title'],
                      units: e['units'],
                      data: e['data'] == '_._' ? '0.0' : e['data']!,
                      minValue: e['minValue'],
                      maxValue: e['maxValue'],
                      range1Value: e['range1Value'],
                      range2Value: e['range2Value'],
                    ),
            )),
          )
          .toList());

  @override
  Widget build(BuildContext context) {
    Widget cardView(PageTitle title, Widget? child, BoxConstraints cons) =>
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SafeArea(
                    child: Scaffold(
                      appBar: AppBar(
                        title: Text(HomeScreen.pageTitle(title)),
                      ),
                      body: openPage(title),
                    ),
                  ),
                ));
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: bdRadius),
            margin: EdgeInsets.all(cons.maxWidth * 0.025),
            child: Card(
              elevation: 8,
              shadowColor: Theme.of(context).colorScheme.primary,
              color: Colors.white.withOpacity(0.65),
              shape: RoundedRectangleBorder(borderRadius: bdRadius),
              child: SizedBox(
                width: cons.maxWidth * 0.275,
                height: cons.maxHeight * 0.4,
                child: Column(
                  children: [
                    Container(
                      width: cons.maxWidth * 0.75,
                      height: cons.maxHeight * 0.05,
                      decoration: BoxDecoration(
                          color: Colors.white, borderRadius: bdRadius),
                      child: Center(
                        child: Text(
                          HomeScreen.pageTitle(title),
                          style: TextStyle(
                              fontSize: 18.0,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                    Expanded(child: child ?? Container()),
                  ],
                ),
              ),
            ),
          ),
        );
    return Consumer<MqttProvider>(
      builder: (context, mqttProv, child) => SizedBox(
        width: cons.maxWidth,
        height: cons.maxHeight * 3,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              cardView(
                  PageTitle.solarHeaterMeter,
                  _gaugeView([
                    {
                      'data': mqttProv.heatingUnitData?.tank1 ?? '_._',
                      'title': 'Tank 1',
                      ...DashboardScreen.temperatureConfig
                    },
                    {
                      'data': mqttProv.heatingUnitData?.tank2 ?? '_._',
                      'title': 'Tank 2',
                      ...DashboardScreen.temperatureConfig
                    },
                    {
                      'data': mqttProv.heatingUnitData?.tank3 ?? '_._',
                      'title': 'Tank 3',
                      ...DashboardScreen.temperatureConfig
                    },
                  ], cons.maxWidth),
                  cons),
              cardView(
                  PageTitle.flowMeter,
                  _gaugeView([
                    {
                      'data': mqttProv.heatingUnitData?.flow2 ?? '_._',
                      'title': 'Flow (S.H)',
                      ...DashboardScreen.flowConfig
                    },
                    {
                      'data': mqttProv.heatingUnitData?.flow1 ?? '_._',
                      'title': 'Flow (H.E)',
                      ...DashboardScreen.flowConfig
                    },
                  ], cons.maxWidth),
                  cons),
              cardView(
                  PageTitle.ductMeter,
                  _gaugeView([
                    {
                      'data': mqttProv.ductMeterData?.temperature ?? '_._',
                      'title': 'Temperature',
                      ...DashboardScreen.temperatureConfig
                    },
                    {
                      'data': mqttProv.ductMeterData?.humidity ?? '_._',
                      'title': 'Humidity',
                      ...DashboardScreen.humidityConfig
                    },
                  ], cons.maxWidth),
                  cons),
              cardView(
                  PageTitle.ambientMeter,
                  _gaugeView([
                    {
                      'data': (mqttProv.heatingUnitData?.ambientTemp)
                              ?.toStringAsFixed(1) ??
                          '_._',
                      'title': 'A.Temp',
                      ...DashboardScreen.temperatureConfig
                    },
                    {
                      'data': (mqttProv.heatingUnitData?.ambientHumidity)
                              ?.toStringAsFixed(1) ??
                          '_._',
                      'title': 'A.Humidity',
                      ...DashboardScreen.humidityConfig
                    },
                    {
                      'data': (mqttProv.heatingUnitData?.ambientIrradiance)
                              ?.toStringAsFixed(1) ??
                          '_._',
                      'title': 'A.Irradiance',
                      ...DashboardScreen.irradianceConfig
                    },
                  ], cons.maxWidth),
                  cons),
              cardView(
                  PageTitle.shedMeter,
                  _gaugeView([
                    {
                      'data': mqttProv.shedMeterData?.temperature ?? '_._',
                      'title': 'Temperature',
                      ...DashboardScreen.temperatureConfig
                    },
                    {
                      'data': mqttProv.shedMeterData?.humidity ?? '_._',
                      'title': 'Humidity',
                      ...DashboardScreen.humidityConfig
                    },
                  ], cons.maxWidth),
                  cons),
              cardView(
                  PageTitle.electricalEnergyMeter,
                  _gaugeView([
                    {
                      'data':
                          mqttProv.electricalEnergyData?.outputEnergy ?? '_._',
                      'title': 'Output Power',
                      ...DashboardScreen.powerConfig
                    },
                    {
                      'data': mqttProv.electricalEnergyData?.pvEnergy ?? '_._',
                      'title': 'Pv Power',
                      ...DashboardScreen.powerConfig
                    },
                  ], cons.maxWidth),
                  cons),
              cardView(
                  PageTitle.thermalEnergyMeter,
                  _gaugeView([
                    {
                      'data': mqttProv.heatingUnitData?.waterEnthalpy!
                              .toStringAsFixed(1) ??
                          '_._',
                      'title': 'Water Thermal Energy',
                      ...DashboardScreen.powerConfig
                    },
                    {
                      'title': 'Pv Thermal Energy',
                      'data': mqttProv.heatingUnitData?.pvEnthalpy
                              .toStringAsFixed(1) ??
                          '_._',
                      ...DashboardScreen.powerConfig
                    },
                  ], cons.maxWidth),
                  cons),
            ],
          ),
        ),
      ),
    );
  }
}
