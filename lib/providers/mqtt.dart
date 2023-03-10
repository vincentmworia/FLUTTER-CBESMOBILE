import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../models/duct_meter.dart';
import '../models/electrical_energy.dart';
import '../models/graph_axis.dart';
import '../models/heating_unit.dart';
import '../models/shed_meter.dart';
import '../private_data.dart';
import '../models/online_user.dart';
import './login_user_data.dart';

enum ConnectionStatus {
  disconnected,
  connected,
}

class MqttProvider with ChangeNotifier {
  late MqttServerClient _mqttClient;
  Timer? timerGraph;
  Timer? timerDummyData;

  MqttServerClient get mqttClient => _mqttClient;

  String? get disconnectTopic => _devicesClient;

  String get disconnectMessage => "Disconnected-$_loginTime";

  HeatingUnit? get heatingUnitData => _heatingUnitData;
  HeatingUnit? _heatingUnitData;

  final List<GraphAxis> temp1GraphData = [];
  final List<GraphAxis> temp2GraphData = [];
  final List<GraphAxis> temp3GraphData = [];

  final List<GraphAxis> flow1GraphData = [];
  final List<GraphAxis> flow2GraphData = [];

  final List<GraphAxis> waterEnthalpyGraphData = [];
  final List<GraphAxis> pvEnthalpyGraphData = [];

  final List<GraphAxis> ambientTempGraphData = [];
  final List<GraphAxis> ambientHumidityGraphData = [];
  final List<GraphAxis> ambientIrradianceGraphData = [];

  final List<GraphAxis> shedTempGraphData = [];
  final List<GraphAxis> shedHumidityGraphData = [];

  final List<GraphAxis> pvElectricalEnergyGraphData = [];
  final List<GraphAxis> outputElectricalEnergyGraphData = [];

  DuctMeter? get ductMeterData => _ductMeterData;
  DuctMeter? _ductMeterData;

  ShedMeter? get shedMeterData => _shedMeterData;
  ShedMeter? _shedMeterData;

  ElectricalEnergy? get electricalEnergyData => _electricalEnergy;
  ElectricalEnergy? _electricalEnergy;

  final List<GraphAxis> temperatureGraphData = [];
  final List<GraphAxis> humidityGraphData = [];

  Map<String, OnlineUser> onlineUsersData = {};

  var _connStatus = ConnectionStatus.disconnected;

  ConnectionStatus get connectionStatus => _connStatus;

  final platform = Platform.isAndroid
      ? "Android"
      : Platform.isWindows
          ? "Windows"
          : Platform.isFuchsia
              ? "Fuchsia"
              : Platform.isIOS
                  ? "IOS"
                  : Platform.isLinux
                      ? "Linux"
                      : "Unknown Operating System";
  String? _deviceId;
  String? _devicesClient;
  String? _loginTime;

  static void removeFirstElement(List list) {
    if (list.length >= (3600 / 2)) {
      list.removeAt(0);
    }
  }

  String _duration(DateTime time) => DateFormat('HH:mm:ss')
      .format(time /*time.subtract(Duration(minutes: delay))*/);

  Future<ConnectionStatus> initializeMqttClient() async {
    final deviceMqttProv = DevicesProvider();

    // onlineUsersData = {};

    _deviceId =
        '&${LoginUserData.getLoggedUser!.email}&${LoginUserData.getLoggedUser!.firstname}&${LoginUserData.getLoggedUser!.lastname}';
    _devicesClient = 'cbes/dekut/devices/$platform/$_deviceId';

    _loginTime = DateTime.now().toIso8601String();
    final connMessage = MqttConnectMessage()
      ..authenticateAs(mqttUsername, mqttPassword)
      ..withWillTopic(_devicesClient!)
      ..withWillMessage('DisconnectedHard-$_loginTime')
      ..withWillRetain()
      ..startClean()
      ..withWillQos(MqttQos.exactlyOnce);

    _mqttClient = MqttServerClient.withPort(
        mqttHost,
        'flutter_client/$_devicesClient/${DateTime.now().toIso8601String()}',
        mqttPort)
      ..secure = true
      ..securityContext = SecurityContext.defaultContext
      ..keepAlivePeriod = 30
      ..securityContext = SecurityContext.defaultContext
      ..connectionMessage = connMessage
      ..onConnected = onConnected
      ..onDisconnected = onDisconnected;
//       ..onSubscribed = onSubscribed
//       ..onUnsubscribed = onUnsubscribed
//       ..onSubscribeFail = onSubscribeFail
// ..pongCallback = pong;

    try {
      await _mqttClient.connect();
    } catch (e) {
      if (kDebugMode) {
        print('\n\nException: $e');
      }
      _mqttClient.disconnect();
      _connStatus = ConnectionStatus.disconnected;
    }

    if (_connStatus == ConnectionStatus.connected) {
      _mqttClient.subscribe("cbes/dekut/#", MqttQos.exactlyOnce);
      timerGraph = Timer.periodic(const Duration(seconds: 10), (timer) {
        final time = DateTime.now();
        if (_shedMeterData != null) {
          removeFirstElement(shedTempGraphData);
          removeFirstElement(shedHumidityGraphData);

          shedTempGraphData.add(GraphAxis(
              _duration(time), double.parse(_shedMeterData!.temperature!)));
          shedHumidityGraphData.add(GraphAxis(
              _duration(time), double.parse(_shedMeterData!.humidity!)));
        }
        if (_electricalEnergy != null) {
          removeFirstElement(pvElectricalEnergyGraphData);
          removeFirstElement(outputElectricalEnergyGraphData);

          outputElectricalEnergyGraphData.add(GraphAxis(
              _duration(time), double.parse(_electricalEnergy!.outputEnergy)));

          pvElectricalEnergyGraphData.add(GraphAxis(
              _duration(time), double.parse(_electricalEnergy!.pvEnergy)));
        }
        if (_ductMeterData != null) {
          removeFirstElement(temperatureGraphData);
          removeFirstElement(humidityGraphData);

          temperatureGraphData.add(GraphAxis(
              _duration(time), double.parse(_ductMeterData!.temperature!)));
          humidityGraphData.add(GraphAxis(
              _duration(time), double.parse(_ductMeterData!.humidity!)));
        }
        if (_heatingUnitData != null) {
          removeFirstElement(temp1GraphData);
          removeFirstElement(temp2GraphData);
          removeFirstElement(temp3GraphData);

          removeFirstElement(flow1GraphData);
          removeFirstElement(flow2GraphData);

          removeFirstElement(waterEnthalpyGraphData);
          removeFirstElement(pvEnthalpyGraphData);

          removeFirstElement(ambientTempGraphData);
          removeFirstElement(ambientHumidityGraphData);
          removeFirstElement(ambientIrradianceGraphData);

          temp1GraphData.add(GraphAxis(
              _duration(time), double.parse(_heatingUnitData!.tank1!)));
          temp2GraphData.add(GraphAxis(
              _duration(time), double.parse(_heatingUnitData!.tank2!)));
          temp3GraphData.add(GraphAxis(
              _duration(time), double.parse(_heatingUnitData!.tank3!)));
          flow1GraphData.add(GraphAxis(
              _duration(time), double.parse(_heatingUnitData!.flow1!)));
          flow2GraphData.add(GraphAxis(
              _duration(time), double.parse(_heatingUnitData!.flow2!)));

          waterEnthalpyGraphData.add(
              GraphAxis(_duration(time), _heatingUnitData!.waterEnthalpy!));
          pvEnthalpyGraphData
              .add(GraphAxis(_duration(time), _heatingUnitData!.pvEnthalpy));

          ambientTempGraphData
              .add(GraphAxis(_duration(time), _heatingUnitData!.ambientTemp));
          ambientHumidityGraphData.add(
              GraphAxis(_duration(time), _heatingUnitData!.ambientHumidity));
          ambientIrradianceGraphData.add(
              GraphAxis(_duration(time), _heatingUnitData!.ambientIrradiance));
        }
        notifyListeners();
      });
      _mqttClient.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final topic = c[0].topic;
        var message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        // TODO Split all the notify listeners to different classes
        if (topic == "cbes/dekut/data/heating_unit") {
          _heatingUnitData =
              HeatingUnit.fromMap(json.decode(message) as Map<String, dynamic>);
          notifyListeners();
          deviceMqttProv.testProv();
        }

        if (topic == "cbes/dekut/data/environment_meter") {
          _ductMeterData =
              DuctMeter.fromMap(json.decode(message) as Map<String, dynamic>);
          notifyListeners();
        }
        if (topic == "cbes/dekut/data/shed_meter") {
          _shedMeterData =
              ShedMeter.fromMap(json.decode(message) as Map<String, dynamic>);
          notifyListeners();
        }
        if (topic == "cbes/dekut/data/electrical_energy") {
          _electricalEnergy = ElectricalEnergy.fromMap(
              json.decode(message) as Map<String, dynamic>);
          notifyListeners();
        }
        if (topic.contains("cbes/dekut/devices")) {
          final deviceData = topic.split('/');
          final deviceUserDetails = deviceData[4].split('&');

          // print(message.split('-')[0]);
          OnlineUser onlineUser = OnlineUser(
            platform: deviceData[3],
            email: deviceUserDetails[1],
            firstName: deviceUserDetails[2],
            lastName: deviceUserDetails[3],
            onlineState: message.split('-')[0] == 'Connected'
                ? OnlineConnectionState.online
                : OnlineConnectionState.offline,
          );
          Map<String, OnlineUser> usersOnline = {
            '${onlineUser.email}-${onlineUser.platform}': onlineUser
          };

          onlineUsersData.addAll(usersOnline);
          deviceMqttProv.setOnlineUsersData(usersOnline);

          notifyListeners();

          // todo Trigger the provider and feed in the data from here instead of notifying listeners?
        }
      });
    }

    return _connStatus;
  }

  void refresh() {
    notifyListeners();
  }

  void publishMsg(String topic, String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    if (kDebugMode) {
      print('Publishing message "$message" to topic $topic');
    }
    _mqttClient.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!,
        retain: true);
  }

  void onConnected() {
    _connStatus = ConnectionStatus.connected;
    publishMsg(_devicesClient!, 'Connected-$_loginTime');
  }

  void onDisconnected() {
    _connStatus = ConnectionStatus.disconnected;
    timerGraph?.cancel();
    timerDummyData?.cancel();
    notifyListeners();
  }
}

// todo Split the data to individual providers
class HeatingUnitProvider with ChangeNotifier {}

class DuctMeterProvider with ChangeNotifier {}

class DevicesProvider with ChangeNotifier {
  Map<String, OnlineUser> onlineUsersData = {};

  void setOnlineUsersData(Map<String, OnlineUser> usrData) {
    onlineUsersData = usrData;
    notifyListeners();
  }

  void testProv() {
    // print(onlineUsersData);
    notifyListeners();
  }
}
