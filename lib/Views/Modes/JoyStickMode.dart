import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:get/get.dart';
import 'package:virtualmousemobile/Controllers/Keys.dart';
import 'package:virtualmousemobile/Views/Modes/Widgets/SensitivitySheet.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class KeyData {
  final String label;
  final double width;
  final String key;
  final int keyCode;

  KeyData(this.label, this.width, this.key, this.keyCode);
}

class JoystickModeScreen extends StatefulWidget {
  final WebSocketChannel channel;
  const JoystickModeScreen({Key? key, required this.channel}) : super(key: key);

  @override
  State<JoystickModeScreen> createState() => _JoystickModeScreenState();
}

class _JoystickModeScreenState extends State<JoystickModeScreen> {
  List<List<KeyData>> keys = [
    [
      KeyData('Esc', 1, 'escape', 27),
      KeyData('F1', 1, 'f1', 112),
      KeyData('F2', 1, 'f2', 113),
      KeyData('F3', 1, 'f3', 114),
      KeyData('F4', 1, 'f4', 115),
      KeyData('F5', 1, 'f5', 116),
      KeyData('F6', 1, 'f6', 117),
      KeyData('F7', 1, 'f7', 118),
      KeyData('F8', 1, 'f8', 119),
      KeyData('F9', 1, 'f9', 120),
      KeyData('F10', 1, 'f10', 121),
      KeyData('F11', 1, 'f11', 122),
      KeyData('F12', 1, 'f12', 123)
    ],
    [
      KeyData('`', 1, '`', 192),
      KeyData('1', 1, '1', 49),
      KeyData('2', 1, '2', 50),
      KeyData('3', 1, '3', 51),
      KeyData('4', 1, '4', 52),
      KeyData('5', 1, '5', 53),
      KeyData('6', 1, '6', 54),
      KeyData('7', 1, '7', 55),
      KeyData('8', 1, '8', 56),
      KeyData('9', 1, '9', 57),
      KeyData('0', 1, '0', 48),
      KeyData('-', 1, '-', 189),
      KeyData('=', 1, '=', 187),
      KeyData('Backspace', 2, 'backspace', 8)
    ],
    [
      KeyData('Tab', 1.5, 'tab', 9),
      KeyData('Q', 1, 'q', 81),
      KeyData('W', 1, 'w', 87),
      KeyData('E', 1, 'e', 69),
      KeyData('R', 1, 'r', 82),
      KeyData('T', 1, 't', 84),
      KeyData('Y', 1, 'y', 89),
      KeyData('U', 1, 'u', 85),
      KeyData('I', 1, 'i', 73),
      KeyData('O', 1, 'o', 79),
      KeyData('P', 1, 'p', 80),
      KeyData('[', 1, '[', 219),
      KeyData(']', 1, ']', 221),
      KeyData('\$', 1.5, '\$',
          188) // Assuming '$' is mapped to 188, adjust if necessary
    ],
    [
      KeyData('Caps Lock', 1.75, 'capslock', 20),
      KeyData('A', 1, 'a', 65),
      KeyData('S', 1, 's', 83),
      KeyData('D', 1, 'd', 68),
      KeyData('F', 1, 'f', 70),
      KeyData('G', 1, 'g', 71),
      KeyData('H', 1, 'h', 72),
      KeyData('J', 1, 'j', 74),
      KeyData('K', 1, 'k', 75),
      KeyData('L', 1, 'l', 76),
      KeyData(';', 1, ';', 186),
      KeyData("'", 1, "'", 222),
      KeyData('Enter', 2.25, 'enter', 13)
    ],
    [
      KeyData('Shift', 2.25, 'shift', 16),
      KeyData('Z', 1, 'z', 90),
      KeyData('X', 1, 'x', 88),
      KeyData('C', 1, 'c', 67),
      KeyData('V', 1, 'v', 86),
      KeyData('B', 1, 'b', 66),
      KeyData('N', 1, 'n', 78),
      KeyData('M', 1, 'm', 77),
      KeyData(',', 1, 'comma', 188),
      KeyData('.', 1, '.', 190),
      KeyData('/', 1, '/', 191),
      KeyData('Shift', 2.75, 'shift', 16)
    ],
    [
      KeyData('Ctrl', 1.25, 'control', 17),
      KeyData('Win', 1.25, 'command', 91),
      KeyData('Alt', 1.25, 'alt', 18),
      KeyData('Space', 6.25, 'space', 32),
      KeyData('Alt', 1.25, 'alt', 18),
      KeyData('Win', 1.25, 'command', 91),
      KeyData('Menu', 1.25, 'menu', 93),
      KeyData('Ctrl', 1.25, 'control', 17)
    ]
  ];

  RxDouble sensitivity = 2.0.obs; // Sensitivity multiplier
  Rx<Offset> direction = Offset(0, 0).obs; // Joystick direction

  bool _isChannelClosed = false;

  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]).then((_) {
      // Wait for 1 second before showing UI
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isLoaded = true;
          });
        }
      });
    });
    direction.value = Offset.zero;
  }

  void _sendMovementData(Offset offset) {
    // Normalize and scale the direction values
    final dx = (offset.dx * 12 * sensitivity.value);
    final dy = (offset.dy * 12 * sensitivity.value);

    // Send movement command only if joystick is moved significantly
    if (dx != 0.00 || dy != 0.00 && !_isChannelClosed) {
      sendMouseMovement(dx, dy, widget.channel);
      // final message = 'move,$dx,$dy';
      // widget.channel.sink.add(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    if (!_isLoaded) {
      return Scaffold(
        backgroundColor: Colors.black, // Optional: Black screen while waiting
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            toolbarHeight: 30,
            backgroundColor: Colors.transparent,
            title: const Text('Joystick Mode'),
          ),
          body: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      JoystickLeftClickButton(channel: widget.channel),
                      VirtualScrollWheel(
                        channel: widget.channel,
                        height: 0.2,
                      ),
                      JoystickRightClickButton(channel: widget.channel)
                    ],
                  ).paddingOnly(left: 20, top: 20),
                ],
              ),
              Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: keys
                    .map((row) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: row
                              .map((keyData) => KeyWidget(
                                  keyData: keyData,
                                  webSocketChannel: widget.channel))
                              .toList(),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        Positioned(
          top: Get.height * 0.1,
          right: 0,
          child: Row(
            children: [
              Joystick(
                stick: Container(
                  width: Get.width * 0.25,
                  height: Get.height * 0.15,
                  decoration: BoxDecoration(
                      color: currentTheme.primaryColor,
                      border: Border.all(color: currentTheme.primaryColor),
                      // borderRadius: BorderRadius.circular(100),
                      shape: BoxShape.circle),
                ),
                base: Container(
                  width: Get.width * 0.3,
                  height: Get.height * 0.4,
                  decoration: BoxDecoration(
                      color: currentTheme.cardColor,
                      border: Border.all(color: currentTheme.primaryColor),
                      // borderRadius: BorderRadius.circular(100),
                      shape: BoxShape.circle),
                ),
                includeInitialAnimation: false,
                period: Duration(milliseconds: 20),
                mode: JoystickMode.all, // Allow movement in all directions
                listener: (details) {
                  direction.value = Offset(details.x, details.y);

                  _sendMovementData(direction.value);
                },
              ),
              JoyStickSensitivitySheet(
                  divisions: 1, sensitivity: sensitivity, min: 1, max: 10),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _isChannelClosed = true;

    super.dispose();
  }
}

class KeyWidget extends StatelessWidget {
  final WebSocketChannel webSocketChannel;
  final KeyData keyData;

  KeyWidget({required this.keyData, required this.webSocketChannel});
  final modifiers = ['shift', 'control', 'alt'];
  @override
  Widget build(BuildContext context) {
    RxBool isTapped = false.obs;
    final currentTheme = Theme.of(context);
    return GestureDetector(
      // wswwwwsssdsss
      onLongPressDown: (details) {
        isTapped.value = true;
        if (modifiers.contains(keyData.key)) {
          sendModifierKeyOnLongPress(keyData.key, webSocketChannel);
        } else {
          sendKeyPress(keyData.key, webSocketChannel);
        }
      },
      // swssssssss
      // onLongPressStart: (details) {},
      onLongPressCancel: () {
        if (modifiers.contains(keyData.key)) {
          sendModifierKeyOnLongPressCancel(keyData.key, webSocketChannel);
        }
        isTapped.value = false;
      },
      onLongPressUp: () {
        if (modifiers.contains(keyData.key)) {
          sendModifierKeyOnLongPressCancel(keyData.key, webSocketChannel);
        }
        isTapped.value = false;
      },
      // onLongPressEnd: (details) {
      //   if (modifiers.contains(keyData.key)) {
      //     sendModifierKeyOnLongPressCancel(keyData.key, webSocketChannel);
      //   }
      //   isTapped.value = false;
      // },

      child: Obx(
        () => Material(
          color: Colors.transparent,
          shadowColor: currentTheme.primaryColor,
          elevation: isTapped.value ? 0 : 10,
          child: Container(
            width: keyData.width * 47.5,
            height: isTapped.value ? 25 : 29,
            decoration: BoxDecoration(
                color: currentTheme.cardColor,
                border: Border.all(color: currentTheme.primaryColor),
                borderRadius: BorderRadius.all(Radius.circular(4)),
                shape: BoxShape.rectangle),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                keyData.label,
                style: TextStyle(color: currentTheme.primaryColorDark),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    // Container(
    //   margin: EdgeInsets.all(2),
    //   width: keyData.width * 43.5,
    //   height: 25,
    //   child: ElevatedButton(
    //     onPressed: () => sendKeyPress(keyData.label, webSocketChannel),
    //     child: Text(keyData.label),
    //   ),
    // );
  }
}
