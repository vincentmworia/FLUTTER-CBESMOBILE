import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/iot_page_template.dart';
import '../widgets/linear_gauge.dart';
import '../widgets/tank_graph.dart';
import '../providers/mqtt.dart';

class HeatingUnitScreen extends StatelessWidget {
  const HeatingUnitScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (_, cons) =>
            Consumer<MqttProvider>(builder: (context, mqttProv, child) {
              final List<Map<String, String>> heatingUnitData = [
                {
                  'title': 'Tank 1 ',
                  'data': mqttProv.heatingUnitData?.tank1 ?? '_._'
                },
                {
                  'title': 'Tank 2',
                  'data': mqttProv.heatingUnitData?.tank2 ?? '_._'
                },
                {
                  'title': 'Tank 3',
                  'data': mqttProv.heatingUnitData?.tank3 ?? '_._'
                },
              ];
              return IotPageTemplate(
                gaugePart: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: heatingUnitData
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
                                  min: 0.0,
                                  max: 100.0,
                                  units: '°C',
                                  gaugeWidth: cons.maxWidth * 0.075),
                            ))
                        .toList()),
                graphPart: MworiaGraph(
                  graphTitle: 'Graph of Temperature against Time',
                  axisTitle: "Temp (°C)",
                  spline1DataSource: mqttProv.temp1GraphData,
                  spline1Title: "Tank 1",
                  spline2DataSource:  mqttProv.temp2GraphData,
                  spline2Title: "Tank 2",
                  spline3DataSource:  mqttProv.temp3GraphData,
                  spline3Title: "Tank 3",
                ),
              );
            }));
  }
}
