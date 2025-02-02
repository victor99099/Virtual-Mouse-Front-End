import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math.dart' as math;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../Controllers/Keys.dart';

class PresentationModeScreen extends StatefulWidget {
  final WebSocketChannel channel;
  const PresentationModeScreen({super.key, required this.channel});

  @override
  _PresentationModeScreenState createState() => _PresentationModeScreenState();
}

class _PresentationModeScreenState extends State<PresentationModeScreen> {
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

      // print("before Maths Degrees ${event.z} , ${event.x}");

      double x = (math.degrees(event.z * -1 * seconds));
      double y = (math.degrees(event.x * -1 * seconds));

      // print("After Maths Degrees $x , $y");

      const double thresholdX = 0.15;
      const double thresholdY = 0.15;

      if (x.abs() <= thresholdX) x = 0;
      if (y.abs() <= thresholdY) y = 0;

      final data = 'pointer2,${x * sensitivity},${y * sensitivity}';

      if (!_isChannelClosed &&
          (x.abs() >= thresholdX || y.abs() >= thresholdY)) {
        // print("Data Going : $data");
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
            'Presentation Mode',
            style: TextStyle(
                fontSize: 20,
                color: currentTheme.primaryColor,
                fontWeight: FontWeight.bold),
          )),
      body: Padding(
        padding: EdgeInsets.only(top: Get.height * 0.15, left: 20.0, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 40,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                UndoButton(channel: widget.channel),
                RedoButton(channel: widget.channel)
              ],
            ),
            DrawingToggleButton(channel: widget.channel),
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

class DrawingToggleButton extends StatefulWidget {
  final WebSocketChannel channel;
  const DrawingToggleButton({super.key, required this.channel});

  @override
  State<DrawingToggleButton> createState() => _DrawingToggleButtonState();
}

class _DrawingToggleButtonState extends State<DrawingToggleButton> {
  @override
  Widget build(BuildContext context) {
    RxBool isTapped = false.obs;
    final currentTheme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        if (isTapped.value) {
          isTapped.value = false;
          sendStopDrawing(widget.channel);
        } else {
          isTapped.value = true;
          sendStartDrawing(widget.channel);
        }
      },
      child: Obx(
        () => Material(
          color: Colors.transparent,
          shadowColor: currentTheme.primaryColor,
          elevation: isTapped.value ? 10 : 0,
          child: Container(
            width: Get.width * 0.394,
            height: Get.height * 0.1,
            decoration: BoxDecoration(
                boxShadow: [
                  isTapped.value
                      ? BoxShadow(
                          color: currentTheme.primaryColor,
                          blurRadius: 10,
                        )
                      : BoxShadow(
                          color: currentTheme.primaryColor, blurRadius: 0),
                ],
                color: currentTheme.cardColor,
                border: Border.all(color: currentTheme.primaryColor),
                borderRadius: BorderRadius.circular(10),
                shape: BoxShape.rectangle),
            child: Icon(
              Icons.brush_outlined,
              size: isTapped.value ? 45 : 40,
              color: isTapped.value ? currentTheme.primaryColor : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class UndoButton extends StatelessWidget {
  final WebSocketChannel channel;
  UndoButton({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    RxBool isTapped = false.obs;
    final currentTheme = Theme.of(context);
    return GestureDetector(
      onTapDown: (details) {
        isTapped.value = true;
      },
      onTapUp: (details) {
        isTapped.value = false;
      },
      onTap: () {
        sendUndoCommand(channel);
      },
      child: Obx(
        () => Container(
          width: Get.width * 0.394,
          height: Get.height * 0.1,
          decoration: BoxDecoration(
              boxShadow: [
                isTapped.value
                    ? BoxShadow(color: currentTheme.primaryColor, blurRadius: 0)
                    : BoxShadow(
                        color: currentTheme.primaryColor,
                        blurRadius: 5,
                        // offset: Offset(-4, 4),
                      ),
              ],
              color: currentTheme.cardColor,
              border: Border.all(color: currentTheme.primaryColor),
              borderRadius: BorderRadius.circular(10),
              shape: BoxShape.rectangle),
          child: Icon(
            Icons.undo_rounded,
            color: currentTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}

class RedoButton extends StatelessWidget {
  final WebSocketChannel channel;
  RedoButton({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    RxBool isTapped = false.obs;
    final currentTheme = Theme.of(context);
    return GestureDetector(
      onTapDown: (details) {
        isTapped.value = true;
      },
      onTapUp: (details) {
        isTapped.value = false;
      },
      onTap: () {
        sendRedoCommand(channel);
      },
      child: Obx(
        () => Container(
          width: Get.width * 0.394,
          height: Get.height * 0.1,
          decoration: BoxDecoration(
              boxShadow: [
                isTapped.value
                    ? BoxShadow(color: currentTheme.primaryColor, blurRadius: 0)
                    : BoxShadow(
                        color: currentTheme.primaryColor,
                        blurRadius: 5,
                        // offset: Offset(4, 4),
                      ),
              ],
              color: currentTheme.cardColor,
              border: Border.all(color: currentTheme.primaryColor),
              borderRadius: BorderRadius.circular(10),
              shape: BoxShape.rectangle),
          child: Icon(
            Icons.redo_rounded,
            color: currentTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}
