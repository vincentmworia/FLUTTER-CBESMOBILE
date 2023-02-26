import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/mqtt.dart';
import '../widgets/iot_page_template.dart';
import '../widgets/radial_gauge_sf.dart';
import '../widgets/tank_graph.dart';

class ThermalEnergyScreen extends StatelessWidget {
  const ThermalEnergyScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, cons) {
      return Consumer<MqttProvider>(builder: (context, mqttProv, child) {
        const gaugeConfig = {
          'units': 'KJ',
          'minValue': 0.0,
          'maxValue': 50.0,
          'range1Value': 15.0,
          'range2Value': 35.0
        };
        final List<Map<String, dynamic>> heatingUnitData = [
          {
            'title': 'Water Thermal Energy',
            'data':
                mqttProv.heatingUnitData?.waterEnthalpy!.toStringAsFixed(1) ??
                    '_._',
            ...gaugeConfig
          },
          {
            'title': 'Pv Thermal Energy',
            'data': mqttProv.heatingUnitData?.pvEnthalpy.toStringAsFixed(1) ??
                '_._',
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
            axisTitle: "Thermal Energy (KJ)",
            area1Title: "Water Thermal Energy (KJ)",
            area1DataSource:   mqttProv.waterEnthalpyGraphData,
            area2Title: "Pv Thermal Energy (KJ)",
            area2DataSource:   mqttProv.pvEnthalpyGraphData,
            graphTitle: 'Graph of Thermal Energy against Time',
          ),
        );
      });
    });
  }
}
