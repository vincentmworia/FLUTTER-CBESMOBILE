import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/mqtt.dart';
import '../widgets/iot_page_template.dart';
import '../widgets/radial_gauge_sf.dart';
import '../widgets/tank_graph.dart';

class FlowMeterScreen extends StatelessWidget {
  const FlowMeterScreen({Key? key}) : super(key: key);

  static const keyMain = "Datetime";
  static const key1 = "Flow Rate (To Solar Heater) in lpm";
  static const key2 = "Flow Rate (To Heat Exchanger) in lpm";

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, cons) {
      return Consumer<MqttProvider>(builder: (context, mqttProv, child) {
        final List<Map<String, String>> heatingUnitData = [
          {
            'title': 'Flow S.H',
            'data': mqttProv.heatingUnitData?.flow2 ?? '_._'
          },
          {
            'title': 'Flow H.E',
            'data': mqttProv.heatingUnitData?.flow1 ?? '_._'
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
                                maxValue: 30.0,
                                range1Value: 10.0,
                                range2Value: 20.0,
                                units: 'lpm',
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList()),
          graphPart: MworiaGraph(
            axisTitle: "Flow (lpm)",
            spline1Title: "Flow (To Solar Heater)",
            spline1DataSource: mqttProv.flow2GraphData,
            spline2Title: "Flow (To Heat Exchanger)",
            spline2DataSource: mqttProv.flow1GraphData,
            graphTitle: 'Graph of Flow Rate against Time',
          ),
        );
      });
    });
  }
}
