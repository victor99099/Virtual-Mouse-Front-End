import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void sendMouseMovement(double dx, double dy, WebSocketChannel channel) {
  final message = 'move,$dx,$dy';
  print(message);
  channel.sink.add(message);
}

void sendPointerMovement(String data, WebSocketChannel channel) {
  channel.sink.add(data);
}

void sendScrollUp(double dx, double dy, WebSocketChannel channel) {
  final message = 'scrollUp,$dx,$dy';
  channel.sink.add(message);
}

// Send scroll down command
void sendScrollDown(double dx, double dy, WebSocketChannel channel) {
  final message = 'scrollDown,$dx,$dy';
  channel.sink.add(message);
}

void sendClick(int button, WebSocketChannel channel) {
  final message = 'click,$button';
  channel.sink.add(message);
}

void sendDoubleTap(WebSocketChannel channel) {
  final message = 'Double';
  channel.sink.add(message);
}

void onLongPressStart(WebSocketChannel channel) {
  final message = 'mouseHoldStart';
  LongPressController longPressController = Get.put(LongPressController());
  longPressController.count.value = 0;
  channel.sink.add(message);

  print("Mouse left-click hold started");
}

// Handle long press end to simulate releasing the left mouse button
void onLongPressEnd(WebSocketChannel channel) {
  final message = 'mouseHoldEnd';
  LongPressController longPressController = Get.put(LongPressController());
  longPressController.count.value = 0;
  channel.sink.add(message);

  print("Mouse left-click hold ended");
}

void sendKeyPress(String key, WebSocketChannel channel) {
  print("Tapped");
  channel.sink.add('key,$key');
}

void sendModifierKeyOnLongPress(String modifier, WebSocketChannel channel) {
  print("Long Press detected for $modifier");
  channel.sink.add('modifier,$modifier');
}

void sendModifierKeyOnLongPressCancel(
    String modifier, WebSocketChannel channel) {
  print("Long Press detected for $modifier");
  channel.sink.add('release,$modifier');
}

void sendStartDrawing(WebSocketChannel channel) {
  channel.sink.add('startDrawing');
}

void sendStopDrawing(WebSocketChannel channel) {
  channel.sink.add('stopDrawing');
}

void sendUndoCommand(WebSocketChannel channel) {
  channel.sink.add('undo');
}

void sendRedoCommand(WebSocketChannel channel) {
  channel.sink.add('redo');
}

void sendColor(WebSocketChannel channel, String color) {
  channel.sink.add('changeColor,$color');
}

class LongPressController extends GetxController {
  RxInt count = 0.obs;
}

class IndicatorController extends GetxController {
  RxDouble indicatorPosition = 0.0.obs;
}

class VirtualScrollWheel extends StatefulWidget {
  final WebSocketChannel channel;
  final double height;
  const VirtualScrollWheel(
      {Key? key, required this.height, required this.channel})
      : super(key: key);
  @override
  _VirtualScrollWheelState createState() => _VirtualScrollWheelState();
}

class _VirtualScrollWheelState extends State<VirtualScrollWheel> {
  IndicatorController indicatorController = Get.put(IndicatorController());
  // The initial position of the scroll indicator (starting from the center)
  // RxDouble _indicatorPosition =
  //     0.0.obs; // Range from -50 to 50 (you can adjust it)

  // Sensitivity for scrolling
  double _sensitivity = 0.05;
  double _previousDx = 0;
  double _previousDy = 0;

  // Handle the gesture updates to simulate wheel movement
  void _onPanUpdate(ScaleUpdateDetails details) {
    final dx = (details.localFocalPoint.dx - _previousDx) * _sensitivity;
    final dy = (details.localFocalPoint.dy - _previousDy) * _sensitivity;

    indicatorController.indicatorPosition.value += dy * 5;
    print(indicatorController.indicatorPosition.value);

    if (dy < 0) {
      sendScrollUp(dx, dy, widget.channel);
    } else if (dy > 0) {
      sendScrollDown(dx, dy, widget.channel);
    }

    _previousDx = details.localFocalPoint.dx;
    _previousDy = details.localFocalPoint.dy;
    // _lastInteractionTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      elevation: 10,
      child: GestureDetector(
        onScaleUpdate: (details) {
          _onPanUpdate(details);
        }, // Detect dragging to scroll
        child: Container(
          width: Get.width * 0.1,
          height: Get.height * widget.height,
          decoration: BoxDecoration(
              color: currentTheme.cardColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: currentTheme.primaryColor, width: 2),
              shape: BoxShape.rectangle),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The wheel
              Padding(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      return ScrollWheelIndicator(
                        position: index,
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ScrollWheelIndicator extends StatelessWidget {
  final int position;

  ScrollWheelIndicator({
    Key? key,
    required this.position,
  }) : super(key: key);

  final IndicatorController indicatorController =
      Get.put(IndicatorController());

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return Obx(
      () {
        // Calculate the offset based on the current indicator position
        double indicatorOffset =
            (position + indicatorController.indicatorPosition.value - 15);

        return Padding(
          padding: EdgeInsets.only(top: 8, left: 4, right: 4),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: currentTheme.cardColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: currentTheme.primaryColor),
                shape: BoxShape.rectangle),
            transform: Matrix4.translationValues(
                0, indicatorOffset, 0), // Move the indicator based on position
          ),
        );
      },
    );
  }
}

class LeftClickButton extends StatelessWidget {
  final WebSocketChannel channel;
  LeftClickButton({super.key, required this.channel});

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
        sendClick(1, channel);
      },
      onLongPressStart: (_) {
        isTapped.value = true;
        onLongPressStart(channel);
      },
      onLongPressEnd: (_) {
        isTapped.value = false;
        onLongPressEnd(channel);
      },
      child: Obx(
        () => Material(
          color: Colors.transparent,
          shadowColor: currentTheme.primaryColor,
          elevation: isTapped.value ? 0 : 10,
          child: Container(
            width: Get.width * 0.455,
            height: isTapped.value ? Get.height * 0.095 : Get.height * 0.1,
            decoration: BoxDecoration(
                color: currentTheme.cardColor,
                border: Border.all(color: currentTheme.primaryColor),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(6)),
                shape: BoxShape.rectangle),
          ),
        ),
      ),
    );
  }
}

class RightClickButton extends StatelessWidget {
  final WebSocketChannel channel;
  RightClickButton({super.key, required this.channel});

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
        sendClick(2, channel);
      },
      child: Obx(
        () => Material(
          color: Colors.transparent,
          shadowColor: currentTheme.primaryColor,
          elevation: isTapped.value ? 0 : 10,
          child: Container(
            width: Get.width * 0.455,
            height: isTapped.value ? Get.height * 0.095 : Get.height * 0.1,
            decoration: BoxDecoration(
                color: currentTheme.cardColor,
                border: Border.all(color: currentTheme.primaryColor),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(6),
                    bottomRight: Radius.circular(10)),
                shape: BoxShape.rectangle),
          ),
        ),
      ),
    );
  }
}

class PointerLeftClickButton extends StatelessWidget {
  final WebSocketChannel channel;
  PointerLeftClickButton({super.key, required this.channel});

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
        sendClick(1, channel);
      },
      onTapCancel: () {
        isTapped.value = false;
      },
      onLongPressStart: (_) {
        isTapped.value = true;
        onLongPressStart(channel);
      },
      onLongPressEnd: (_) {
        isTapped.value = false;
        onLongPressEnd(channel);
      },
      child: Obx(
        () => Material(
          color: Colors.transparent,
          shadowColor: currentTheme.primaryColor,
          elevation: isTapped.value ? 0 : 10,
          child: Container(
            width: Get.width * 0.394,
            height: isTapped.value ? Get.height * 0.095 : Get.height * 0.1,
            decoration: BoxDecoration(
                color: currentTheme.cardColor,
                border: Border.all(color: currentTheme.primaryColor, width: 2),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  topLeft: Radius.circular(10),
                ),
                shape: BoxShape.rectangle),
          ),
        ),
      ),
    );
  }
}

class PointerRightClickButton extends StatelessWidget {
  final WebSocketChannel channel;
  PointerRightClickButton({super.key, required this.channel});

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
        sendClick(2, channel);
      },
      onTapCancel: () {
        isTapped.value = false;
      },
      child: Obx(
        () => Material(
          color: Colors.transparent,
          shadowColor: currentTheme.primaryColor,
          elevation: isTapped.value ? 0 : 10,
          child: Container(
            width: Get.width * 0.394,
            height: isTapped.value ? Get.height * 0.095 : Get.height * 0.1,
            decoration: BoxDecoration(
                color: currentTheme.cardColor,
                border: Border.all(color: currentTheme.primaryColor, width: 2),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(10),
                    topRight: Radius.circular(10)),
                shape: BoxShape.rectangle),
          ),
        ),
      ),
    );
  }
}

class JoystickLeftClickButton extends StatelessWidget {
  final WebSocketChannel channel;
  JoystickLeftClickButton({super.key, required this.channel});

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
        sendClick(1, channel);
      },
      onTapCancel: () {
        isTapped.value = false;
      },
      onLongPressStart: (_) {
        isTapped.value = true;
        onLongPressStart(channel);
      },
      onLongPressEnd: (_) {
        isTapped.value = false;
        onLongPressEnd(channel);
      },
      child: Obx(
        () => Material(
          color: Colors.transparent,
          shadowColor: currentTheme.primaryColor,
          elevation: isTapped.value ? 0 : 10,
          child: Container(
            width: Get.width * 0.2,
            height: isTapped.value ? Get.height * 0.15 : Get.height * 0.2,
            decoration: BoxDecoration(
                color: currentTheme.cardColor,
                border: Border.all(color: currentTheme.primaryColor, width: 2),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  topLeft: Radius.circular(25),
                ),
                shape: BoxShape.rectangle),
          ),
        ),
      ),
    );
  }
}

class JoystickRightClickButton extends StatelessWidget {
  final WebSocketChannel channel;
  JoystickRightClickButton({super.key, required this.channel});

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
        sendClick(2, channel);
      },
      onTapCancel: () {
        isTapped.value = false;
      },
      child: Obx(
        () => Material(
          color: Colors.transparent,
          shadowColor: currentTheme.primaryColor,
          elevation: isTapped.value ? 0 : 10,
          child: Container(
            width: Get.width * 0.2,
            height: isTapped.value ? Get.height * 0.15 : Get.height * 0.2,
            decoration: BoxDecoration(
                color: currentTheme.cardColor,
                border: Border.all(color: currentTheme.primaryColor, width: 2),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(10),
                    topRight: Radius.circular(25)),
                shape: BoxShape.rectangle),
          ),
        ),
      ),
    );
  }
}
