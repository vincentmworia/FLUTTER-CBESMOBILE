import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/mqtt.dart';
import '../widgets/iot_page_template.dart';
import '../widgets/radial_gauge_sf.dart';
import '../widgets/tank_graph.dart';

class ElectricalEnergyScreen extends StatelessWidget {
  const ElectricalEnergyScreen({Key? key}) : super(key: key);

  static const metrics = 'KW';
  static const key1 = "Output Electrical Energy ($metrics)";
  static const key2 = "Pv Electrical Energy ($metrics)";

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, cons) {
      return Consumer<MqttProvider>(builder: (context, mqttProv, child) {
        const gaugeConfig = {
          'units': metrics,
          'minValue': 0.0,
          'maxValue': 100.0,
          'range1Value': 15.0,
          'range2Value': 65.0
        };
        final List<Map<String, dynamic>> heatingUnitData = [
          {
            'title': 'Output Electrical Energy',
            'data': mqttProv.electricalEnergyData?.outputEnergy ?? '_._',
            ...gaugeConfig
          },
          {
            'title': 'Pv Electrical Energy',
            'data': mqttProv.electricalEnergyData?.pvEnergy ?? '_._',
            ...gaugeConfig
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
                                minValue: e['minValue'],
                                maxValue: e['maxValue'],
                                range1Value: e['range1Value'],
                                range2Value: e['range2Value'],
                                units: e['units']!,
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList()),
          graphPart: MworiaGraph(
            axisTitle: "Electrical Energy $metrics",
            area1Title: key1,
            area1DataSource: mqttProv.outputElectricalEnergyGraphData,
            area2Title: key2,
            area2DataSource: mqttProv.pvElectricalEnergyGraphData,
            graphTitle: 'Graph of Electrical Energy against Time',
          ),
        );
      });
    });
  }
}
