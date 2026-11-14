import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math.dart' as math;
import 'package:virtualmousemobile/Views/Modes/Widgets/SensitivitySheet.dart';
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
  RxDouble sensitivity = 2.0.obs;
  String? connectionStatus;
  StreamSubscription? gyroscopeSubscription;
  DateTime lastMouseMovement = DateTime.now();
  // Timer? _throttleTimer;

  @override
  void initState() {
    super.initState();
    setState(() {
      startGyroscopeListening();
    });
    sendColor(
        widget.channel, Get.find<DrawingColorController>().selectedColor.value);
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

      final data = 'pointer2,${x * sensitivity.value},${y * sensitivity.value}';

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
      bottomSheet: PresentationSensitivitySheet(
          channel: widget.channel,
          divisions: 1,
          sensitivity: sensitivity,
          min: 1,
          max: 10),
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
        padding: EdgeInsets.only(left: 20.0, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 30,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PresentationButton(
                  channel: widget.channel,
                  callbackAction: () {
                    sendStartSlideCommand(widget.channel);
                  },
                  name: "Start",
                ),
                PresentationButton(
                  channel: widget.channel,
                  callbackAction: () {
                    sendEndSlideCommand(widget.channel);
                  },
                  name: "End",
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PresentationButton(
                  channel: widget.channel,
                  callbackAction: () {
                    sendPrevSlideCommand(widget.channel);
                  },
                  name: "Previous",
                ),
                PresentationButton(
                  channel: widget.channel,
                  callbackAction: () {
                    sendNextSlideCommand(widget.channel);
                  },
                  name: "Next",
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DrawingToggleButton(channel: widget.channel),
                CenterButton(channel: widget.channel)
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
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
    sendStopDrawing(widget.channel);
    super.dispose();
  }
}

class PresentationButton extends StatelessWidget {
  final WebSocketChannel channel;
  final String name;
  final GestureTapCallback callbackAction;
  const PresentationButton(
      {super.key,
      required this.callbackAction,
      required this.channel,
      required this.name});

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
      onTap: callbackAction,
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
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                  fontSize: 18,
                  color:
                      isTapped.value ? currentTheme.primaryColor : Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class CenterButton extends StatelessWidget {
  final WebSocketChannel channel;
  const CenterButton({super.key, required this.channel});

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
        final message = 'Center';
        channel.sink.add(message);
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
          child: Center(
            child: Text(
              "Re Center",
              style: TextStyle(
                  fontSize: 18,
                  color:
                      isTapped.value ? currentTheme.primaryColor : Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
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
  const UndoButton({super.key, required this.channel});

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
  const RedoButton({super.key, required this.channel});

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
