import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mqtt.dart';

class IotPageTemplate extends StatefulWidget {
  const IotPageTemplate({
    Key? key,
    required this.gaugePart,
    required this.graphPart,
  }) : super(key: key);
  final Widget gaugePart;
  final Widget graphPart;

  @override
  State<IotPageTemplate> createState() => _IotPageTemplateState();
}

class _IotPageTemplateState extends State<IotPageTemplate> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LayoutBuilder(builder: (_, cons) {
          return Consumer<MqttProvider>(
              builder: (context, mqttProv, child) => SizedBox(
                    height: cons.maxHeight,
                    width: cons.maxWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: cons.maxHeight * 0.05,
                            horizontal: cons.maxWidth * 0.005,
                          ),
                          width: cons.maxWidth,
                          height: cons.maxHeight * 0.3,
                          child: widget.gaugePart,
                        ),
                        Expanded(child: widget.graphPart),
                      ],
                    ),
                  ));
        }),
      ],
    );
  }
}
