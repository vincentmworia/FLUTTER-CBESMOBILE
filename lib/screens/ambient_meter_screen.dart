import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mqtt.dart';

import '../widgets/iot_page_template.dart';
import '../widgets/linear_gauge.dart';
import '../widgets/tank_graph.dart';

class AmbientMeterScreen extends StatelessWidget {
  const AmbientMeterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (_, cons) =>
            Consumer<MqttProvider>(builder: (context, mqttProv, child) {
              final List<Map<String, String>> ambientMeterData = [
                {
                  'title': 'Temperature',
                  'data': (mqttProv.heatingUnitData?.ambientTemp)
                          ?.toStringAsFixed(1) ??
                      '_._',
                  'min': '0.0',
                  'max': '100.0',
                  'units': '°C',
                },
                {
                  'title': 'Humidity',
                  'data': (mqttProv.heatingUnitData?.ambientHumidity)
                          ?.toStringAsFixed(1) ??
                      '_._',
                  'min': '0.0',
                  'max': '100.0',
                  'units': '%',
                },
                {
                  'title': 'Irradiance',
                  'data': (mqttProv.heatingUnitData?.ambientIrradiance)
                          ?.toStringAsFixed(1) ??
                      '_._',
                  'units': 'w/m²',
                  'min': '0.0',
                  'max': '2000.0',
                },
              ];
              return IotPageTemplate(
                gaugePart: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ambientMeterData
                        .map((e) => Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              color: Colors.white.withOpacity(0.85),
                              shadowColor:
                                  Theme.of(context).colorScheme.primary,
                              child: LinearGauge(
                                  title: e['title']!,
                                  data: e['data'] == '_._' ? '0.0' : e['data']!,
                                  min: double.parse(e['min']!),
                                  max: double.parse(e['max']!),
                                  units: e['units']!,
                                  gaugeWidth: cons.maxWidth * 0.075),
                            ))
                        .toList()),
                graphPart: MworiaGraph(
                  graphTitle: 'Graph of Ambience against Time',
                  axisTitle: "Temp (°C)",
                  spline1DataSource:  mqttProv.ambientTempGraphData,
                  spline1Title: "Ambient Temperature",
                  spline2DataSource: mqttProv.ambientHumidityGraphData,
                  spline2Title: "Ambient Humidity",
                  spline3DataSource:  mqttProv.ambientIrradianceGraphData,
                  spline3Title: "Ambient Irradiance",
                ),
              );
            }));
  }
}
