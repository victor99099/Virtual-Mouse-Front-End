import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:virtualmousemobile/Views/Modes/Widgets/SensitivitySheet.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../Controllers/Keys.dart';

class TouchpadModeScreen extends StatefulWidget {
  final WebSocketChannel channel;
  const TouchpadModeScreen({Key? key, required this.channel}) : super(key: key);

  @override
  _TouchpadModeScreenState createState() => _TouchpadModeScreenState();
}

class _TouchpadModeScreenState extends State<TouchpadModeScreen> {
  bool _isChannelClosed = false;

  LongPressController longPressController = Get.put(LongPressController());

  double _previousDx = 0;
  double _previousDy = 0;
  RxDouble sensitivity = 5.0.obs;

  // Threshold for movement detection
  static const double movementThreshold = 2;
  static const int throttleDuration = 10;
  DateTime? _lastInteractionTime;

  Timer? _throttleTimer;

  void throttledSendMouseMovement(double dx, double dy) {
    if (_throttleTimer == null ||
        !_throttleTimer!.isActive && !_isChannelClosed) {
      sendMouseMovement(dx, dy, widget.channel);

      // Start a timer to throttle further events
      _throttleTimer = Timer(Duration(milliseconds: throttleDuration), () {
        _throttleTimer = null; // Reset the timer
      });
    }
  }

  // Send scroll up command

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return Scaffold(
      bottomSheet: SensitivitySheet(divisions: 30, sensitivity: sensitivity, min: 1, max: 30),
      backgroundColor: currentTheme.canvasColor,
      appBar: AppBar(
          iconTheme: IconThemeData(color: currentTheme.primaryColor),
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Touchpad Mode',
            style: TextStyle(
                fontSize: 20,
                color: currentTheme.primaryColor,
                fontWeight: FontWeight.bold),
          )),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: (details) {
              _previousDx = details.localFocalPoint.dx;
              _previousDy = details.localFocalPoint.dy;
              _lastInteractionTime = DateTime.now();
            },
            onScaleUpdate: (details) {
              if (details.pointerCount == 1) {
                // print("Focal X${details.localFocalPoint.dx - _previousDx}");
                // print("Focal Y${details.localFocalPoint.dy - _previousDy}");
                var dx =
                    (details.localFocalPoint.dx - _previousDx) * sensitivity.value;
                var dy =
                    (details.localFocalPoint.dy - _previousDy) * sensitivity.value;

                print("$dx , $dy");
                if (dx.abs() > movementThreshold ||
                    dy.abs() > movementThreshold) {
                  if (dx.abs() < movementThreshold) {
                    dx = 0;
                  }
                  if (dy.abs() < movementThreshold) {
                    dy = 0;
                  }

                  throttledSendMouseMovement(dx, dy);
                  _previousDx = details.localFocalPoint.dx;
                  _previousDy = details.localFocalPoint.dy;
                  _lastInteractionTime = DateTime.now();
                }
              } else if (details.pointerCount == 2) {
                // Handle scroll movement
                var dx =
                    (details.localFocalPoint.dx - _previousDx) * sensitivity.value;
                var dy =
                    (details.localFocalPoint.dy - _previousDy) * sensitivity.value;
                if (dx.abs() < movementThreshold) {
                  dx = 0;
                }
                if (dy.abs() < movementThreshold) {
                  dy = 0;
                }
                if (dy < 0) {
                  sendScrollUp(dx, dy, widget.channel);
                } else if (dy > 0) {
                  sendScrollDown(dx, dy, widget.channel);
                }

                _previousDx = details.localFocalPoint.dx;
                _previousDy = details.localFocalPoint.dy;
                _lastInteractionTime = DateTime.now();
              }
            },
            onTap: () {
              final now = DateTime.now();
              if (_lastInteractionTime == null ||
                  now.difference(_lastInteractionTime!).inMilliseconds > 100) {
                sendClick(1, widget.channel); // Left click
              }
            },
            onDoubleTap: () {
              sendDoubleTap(widget.channel);
            },
            onLongPressMoveUpdate: (details) {
              // print("count $count");
              if (longPressController.count.value > 2) {
                var dx = (details.localPosition.dx - _previousDx) * sensitivity.value;
                var dy = (details.localPosition.dy - _previousDy) * sensitivity.value;
                if (dx.abs() < movementThreshold) {
                  dx = 0;
                }
                if (dy.abs() < movementThreshold) {
                  dy = 0;
                }
                if (dx.abs() > movementThreshold ||
                    dy.abs() > movementThreshold) {
                  throttledSendMouseMovement(dx, dy);
                  _previousDx = details.localPosition.dx;
                  _previousDy = details.localPosition.dy;
                  _lastInteractionTime = DateTime.now();
                }
              } else {
                _previousDx = details.localPosition.dx;
                _previousDy = details.localPosition.dy;
                _lastInteractionTime = DateTime.now();
                print(_previousDx);

                longPressController.count.value += 1;
              }
            },
            onLongPressStart: (_) => onLongPressStart(widget.channel),
            onLongPressEnd: (_) => onLongPressEnd(widget.channel),
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16),
              child: Container(
                padding: EdgeInsets.all(10),
                width: Get.width,
                height: Get.height * 0.5,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: currentTheme.primaryColor, blurRadius: 10),
                    ],
                    color: currentTheme.cardColor,
                    border: Border.all(color: currentTheme.primaryColor),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(0)),
                    shape: BoxShape.rectangle),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LeftClickButton(channel: widget.channel),
                RightClickButton(channel: widget.channel)
              ],
            ),
          ),
        ],
      ).paddingOnly(top: Get.height * 0.05),
    );
  }

  @override
  void dispose() {
    _isChannelClosed = true;
    // widget.channel.sink.close();
    super.dispose();
  }
}
