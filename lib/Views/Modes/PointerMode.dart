import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math.dart' as math;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../Controllers/Keys.dart';

class PointerModeScreen extends StatefulWidget {
  final WebSocketChannel channel;
  const PointerModeScreen({super.key, required this.channel});

  @override
  _PointerModeScreenState createState() => _PointerModeScreenState();
}

class _PointerModeScreenState extends State<PointerModeScreen> {
  bool _isChannelClosed = false;
  bool isCursorMovingEnabled = false;
  double sensitivity = 2;
  String? connectionStatus;
  StreamSubscription? gyroscopeSubscription;
  DateTime lastMouseMovement = DateTime.now();
  Timer? _throttleTimer;

  @override
  void initState() {
    super.initState();
    setState(() {
      startGyroscopeListening();
    });
  }

  void startGyroscopeListening() {
    gyroscopeSubscription =
        gyroscopeEventStream(samplingPeriod: SensorInterval.gameInterval)
            .listen((GyroscopeEvent event) {
      // if (_throttleTimer?.isActive ?? false)
      //   return; // Skip if throttling is active
      // _throttleTimer = Timer(const Duration(milliseconds: 10), () {
      var seconds =
          event.timestamp.difference(lastMouseMovement).inMicroseconds /
              (pow(10, 6));
      lastMouseMovement = event.timestamp;

      double x = (math.degrees(event.z * -1 * seconds));
      double y = (math.degrees(event.x * -1 * seconds));

      // print("$x , $y");

      const double thresholdX = 0.15;
      const double thresholdY = 0.15;

      if (x.abs() <= thresholdX) x = 0;
      if (y.abs() <= thresholdY) y = 0;

      final data = 'pointer2,${x * sensitivity},${y * sensitivity}';

      if (!_isChannelClosed &&
          (x.abs() >= thresholdX || y.abs() >= thresholdY)) {
        sendPointerMovement(data, widget.channel);
      }
      // });
    });
  }

  void stopGyroscopeListening() {
    gyroscopeSubscription?.cancel();
    gyroscopeSubscription = null;
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return Scaffold(
      backgroundColor: currentTheme.canvasColor,
      appBar: AppBar(
          iconTheme: IconThemeData(color: currentTheme.primaryColor),
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Pointer Mode',
            style: TextStyle(
                fontSize: 20,
                color: currentTheme.primaryColor,
                fontWeight: FontWeight.bold),
          )),
      body: Padding(
        padding:
            EdgeInsets.only(left: 20.0, right: 20, bottom: Get.height * 0.2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 100,
          children: [
            Center(
              child: Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                      padding: WidgetStatePropertyAll(EdgeInsets.all(32)),
                      backgroundColor:
                          WidgetStatePropertyAll(currentTheme.cardColor),
                      elevation: WidgetStatePropertyAll(10),
                      shadowColor:
                          WidgetStatePropertyAll(currentTheme.primaryColor),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: currentTheme.primaryColor, width: 2)))),
                  onPressed: () {
                    setState(() {
                      startGyroscopeListening();
                    });
                    final message = 'Center';
                    widget.channel.sink.add(message);
                  },
                  child: Text(
                    "Re Center",
                    style: TextStyle(
                        fontSize: 18,
                        color: currentTheme.primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PointerLeftClickButton(channel: widget.channel),
                VirtualScrollWheel(
                  channel: widget.channel,
                  height: 0.1,
                ),
                PointerRightClickButton(channel: widget.channel)
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    gyroscopeSubscription?.cancel();
    _isChannelClosed = true;
    super.dispose();
  }
}
