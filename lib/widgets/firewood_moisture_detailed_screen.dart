import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield_new.dart';
import '../helpers/custom_data.dart';
import '../models/graph_axis.dart';
import '../providers/https_protocol.dart';
import '../screens/firewood_moisture_screen.dart';
import './tank_graph.dart';

class FirewoodMoistureDetailedScreen extends StatefulWidget {
  const FirewoodMoistureDetailedScreen(
      {Key? key,
      required this.op,
      required this.pageData,
      required this.cancelPage,
      required this.deleteStack,
      required this.addMoistureLevelToStack,
      required this.changeLoadingStatus,
      required this.cons,
      required this.removeMoistureItem})
      : super(key: key);
  final double op;
  final Map<String, dynamic> pageData;
  final Function cancelPage;
  final Function deleteStack;
  final Function addMoistureLevelToStack;
  final Function changeLoadingStatus;
  final Function removeMoistureItem;
  final BoxConstraints cons;

  @override
  State<FirewoodMoistureDetailedScreen> createState() =>
      _FirewoodMoistureDetailedScreenState();
}

class _FirewoodMoistureDetailedScreenState
    extends State<FirewoodMoistureDetailedScreen> {

  final _dateTimeController = TextEditingController();
  final _moistureLevelController = TextEditingController();
  var _selectedDateAndTime = '';
  @override
  void dispose() {
    super.dispose();
    _dateTimeController.dispose();
    _moistureLevelController.dispose();
  }

  final graphData = <GraphAxis>[];
  var graphView = true;

  @override
  Widget build(BuildContext context) {
    graphData.clear();
    (widget.pageData[widget.pageData.keys.first] as Map).forEach((key, value) {
      graphData.add(GraphAxis.fromMap({key: value}));
    });
    graphData
        .sort((a, b) => DateTime.parse(a.x).compareTo(DateTime.parse(b.x)));
    return AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: widget.op,
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: 1000,
            color: Colors.white,
            child: Column(
              children: [
                Row(
                   children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: IconButton(
                        iconSize: 30.0,
                        icon: Icon(
                          Icons.cancel,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        onPressed: () async => await widget.cancelPage(),
                      ),
                    ),
                    Expanded(
                        child: Center(
                      child: Text(
                        widget.pageData.keys.first,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 25),
                      ),
                    )),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: IconButton(
                        iconSize: 30.0,
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () async =>
                            await widget.deleteStack(widget.pageData.keys.first),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: LayoutBuilder(builder: (context, cons) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              vertical: cons.maxHeight * 0.05,
                              horizontal: cons.maxWidth * 0.005,
                            ),
                            width: cons.maxWidth * 0.85,
                            // height:500,
                            child:
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              color: Colors.white.withOpacity(0.85),
                              shadowColor:
                              Theme.of(context).colorScheme.primary,
                              child: Column(
                                children: [
                                  if (MediaQuery.of(context).size.height > 650)
                                    Center(
                                      child: Text(
                                        "Add Moisture Level",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontSize: 22),
                                      ),
                                    ),
                                  Expanded(
                                    child: SizedBox(
                                      // height: cons.maxHeight * 0.5,
                                      width: cons.maxWidth * 0.75,
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          DateTimeField(
                                            format:
                                            DateFormat("yyyy-MM-dd HH:mm"),
                                            decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                contentPadding:
                                                const EdgeInsets.all(20),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                      width: 0.8),
                                                ),
                                                hintText: 'Select Date and Time',
                                                counterText: "Date and Time"),
                                            // format: DateFormat("EEE, MMM d yyyy h:mm a"),
                                            controller: _dateTimeController,

                                            // onFieldSubmitted: (value) {
                                            // },
                                            // validator: ,
                                            // cursorRadius: Radius.circular(200),

                                            showCursor: true,
                                            validator: (value) {
                                              if (value == null) {
                                                return "Select Date and Time";
                                              }
                                              return null;
                                            },

                                            onShowPicker:
                                                (context, currentValue) async {
                                              final currentTime = DateTime.now();
                                              final date = await showDatePicker(
                                                  context: context,
                                                  firstDate:
                                                  DateTime(2023, 1, 10, 0, 0),
                                                  initialDate: currentValue ??
                                                      DateTime.now(),
                                                  lastDate: DateTime(
                                                    currentTime.year,
                                                    currentTime.month,
                                                    currentTime.day,
                                                    currentTime.hour,
                                                    currentTime.minute,
                                                  ));
                                              if (date != null) {
                                                TimeOfDay? time;
                                                await Future.delayed(
                                                    Duration.zero)
                                                    .then((value) async => time =
                                                await showTimePicker(
                                                  context: context,
                                                  initialTime: TimeOfDay
                                                      .fromDateTime(
                                                      currentValue ??
                                                          DateTime
                                                              .now()),
                                                ));

                                                final dateTimeSelected =
                                                DateTimeField.combine(
                                                    date, time);

                                                _dateTimeController
                                                    .text = DateFormat(
                                                    "EEE, MMM d yyyy h:mm a")
                                                    .format(dateTimeSelected);
                                                _selectedDateAndTime =
                                                    DateFormat("yyyy-MM-dd HH:mm")
                                                        .format(dateTimeSelected);
                                              } else {
                                                return currentValue;
                                              }
                                              return null;
                                            },
                                          ),
                                          TextField(
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(30),
                                                borderSide:
                                                const BorderSide(width: 0.8),
                                              ),
                                              hintText: 'Enter Moisture Level',
                                              counterText: 'Moisture Level',
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            controller: _moistureLevelController,
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: () async {
                                              ScaffoldMessenger.of(context)
                                                  .hideCurrentSnackBar();
                                              if (_selectedDateAndTime == '') {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                    content:
                                                    Text("Enter Date")));
                                                return;
                                              }
                                              if (_moistureLevelController.text ==
                                                  '') {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        "Enter Moisture Level")));
                                                return;
                                              }
                                              if (double.tryParse(
                                                  _moistureLevelController
                                                      .text) ==
                                                  null) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        "Moisture Level is a number")));
                                                return;
                                              }
                                              await widget
                                                  .addMoistureLevelToStack(
                                                  widget.pageData.keys.first,
                                                  _selectedDateAndTime,
                                                  _moistureLevelController
                                                      .text);
                                            },
                                            icon: const Icon(Icons.add),
                                            label: const Text('Add'),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    if (graphView)
                                      MworiaGraph(
                                        axisTitle: "Firewood Moisture Level (%)",
                                        spline1Title: "Firewood Moisture Level",
                                        spline1DataSource: graphData,
                                        graphTitle:
                                            'Graph of Firewood Moisture Level against Time',
                                      ),
                                    if (!graphView)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 30.0, right: 10, left: 10),
                                        child: ListView(
                                            children: graphData
                                                .map((e) => Card(
                                                      elevation: 4,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                      color: Colors.white
                                                          .withOpacity(0.85),
                                                      shadowColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                      child: Container(
                                                        width:
                                                            cons.maxWidth * 0.01,
                                                        margin:
                                                            const EdgeInsets.all(
                                                                10),
                                                        padding: const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 20),
                                                        child: ListTile(
                                                          title: Text(DateFormat(
                                                                  'MMM d yyyy  hh:mm a')
                                                              .format(
                                                                  DateTime.parse(
                                                                      e.x))),
                                                          subtitle: Text(
                                                              '${e.y.toString()} %'),
                                                          trailing: IconButton(
                                                            onPressed: () async {
                                                              widget
                                                                  .changeLoadingStatus(
                                                                      true);
                                                              await FirewoodMoistureScreen
                                                                  .showAlertDialog(
                                                                      'Are you sure?',
                                                                      () async {
                                                                try {
                                                                  await HttpProtocol.deleteFirewoodStackData(
                                                                      stackName: widget
                                                                          .pageData
                                                                          .keys
                                                                          .first,
                                                                      date: e.x);

                                                                  widget.removeMoistureItem(
                                                                      widget
                                                                          .pageData
                                                                          .keys
                                                                          .first,
                                                                      e.x);
                                                                  setState(() {
                                                                    graphData.removeWhere(
                                                                        (element) =>
                                                                            element
                                                                                .x ==
                                                                            e.x);
                                                                  });
                                                                } catch (e) {
                                                                  await customDialog(
                                                                      context,
                                                                      "Operation failed");
                                                                }
                                                              }, context);

                                                              widget
                                                                  .changeLoadingStatus(
                                                                      false);
                                                            },
                                                            icon: const Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ))
                                                .toList()),
                                      ),
                                    Positioned(
                                        top: 1,
                                        right: 5,
                                        child: Switch.adaptive(
                                            value: graphView,
                                            onChanged: (val) {
                                              setState(() {
                                                graphView = val;
                                              });
                                            }))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                )
              ],
            ),
          ),
        ));
  }
}
