import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/mqtt.dart';
import '../widgets/iot_page_template.dart';
import '../widgets/radial_gauge_sf.dart';
import '../widgets/tank_graph.dart';

class ShedMeterScreen extends StatelessWidget {
  const ShedMeterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, cons) {
      return Consumer<MqttProvider>(builder: (context, mqttProv, child) {
        final List<Map<String, String>> heatingUnitData = [
          {
            'title': 'Temperature',
            'data': mqttProv.shedMeterData?.temperature ?? '_._'
          },
          {
            'title': 'Humidity',
            'data': mqttProv.shedMeterData?.humidity ?? '_._'
          },
        ];
        return IotPageTemplate(
          gaugePart: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: heatingUnitData
                  .map((e) => Expanded(
                        child: Container(
                          margin: EdgeInsets.all(cons.maxWidth * 0.02),
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            color: Colors.white.withOpacity(0.85),
                            shadowColor: Theme.of(context).colorScheme.primary,
                            child: SizedBox(
                              width: 175,
                              height: double.infinity,
                              child: SyncfusionRadialGauge(
                                title: e['title']!,
                                data: e['data'] == '_._' ? '0.0' : e['data']!,
                                minValue: 0.0,
                                maxValue: 100.0,
                                range1Value: 20.0,
                                range2Value: 55.0,
                                units: e['title'] == 'Temperature' ? '°C' : '%',
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList()),
          graphPart: MworiaGraph(
            axisTitle: "Temp (°C) and Humidity (%)",
            spline1Title: "Temperature (°C)",
            spline1DataSource: mqttProv.shedTempGraphData,
            spline2Title: "Humidity (%)",
            spline2DataSource:   mqttProv.shedHumidityGraphData,
            graphTitle: 'Graph of Temperature and Humidity against Time',
          ),
        );
      });
    });
  }
}
