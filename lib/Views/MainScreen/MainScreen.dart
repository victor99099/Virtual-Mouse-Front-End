import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:virtualmousemobile/Views/Modes/PointerMode.dart';
import 'package:virtualmousemobile/Views/Modes/PresentationMode.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../Modes/JoyStickMode.dart';
import '../Modes/TouchPasMode.dart';

class MainControlScreen extends StatefulWidget {
  final WebSocketChannel channel;

  MainControlScreen({required this.channel});

  @override
  State<MainControlScreen> createState() => _MainControlScreenState();
}

class _MainControlScreenState extends State<MainControlScreen> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();

    // Set orientation first
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]).then((_) {
      // Wait for 1 second before showing UI
      Future.delayed(Duration(seconds: 0), () {
        if (mounted) {
          setState(() {
            _isLoaded = true;
          });
        }
      });
    });
  }

  @override
  void dispose(){
    _isLoaded = false;
    super.dispose();
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
    return Scaffold(
      backgroundColor: currentTheme.canvasColor,
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: Center(
            child: Text(
              'Select Mode',
              style: TextStyle(
                  fontSize: 24,
                  color: currentTheme.primaryColor,
                  fontWeight: FontWeight.bold),
            ),
          )),
      body: ListView(
        children: [
          // ListTile(
          //   title: Text('Touchpad Mode'),
          //   onTap: () => Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (_) => TouchpadModeScreen(
          //         channel: channel,
          //       ),
          //     ),
          //   ),
          // ),
          // ListTile(
          //   title: Text('JoyStick Mode'),
          //   onTap: () => Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (_) => JoystickModeScreen(
          //         channel: channel,
          //       ),
          //     ),
          //   ),
          // ),
          // ListTile(
          //   title: Text('Final Pointer'),
          //   onTap: () => Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (_) => PointerModeScreen(
          //         channel: channel,
          //       ),
          //     ),
          //   ),
          // ),
          ModeBox(
              isPadded: false,
              desc: "Touchpad exactly like in laptops",
              img: "assets/TouchpadLogo.png",
              name: "Touchpad Mode",
              onTap: () {
                Get.to(() => TouchpadModeScreen(channel: widget.channel));
              }),
          ModeBox(
              isPadded: true,
              desc: "Virtual stick for controlling cursor with accuracy ",
              img: "assets/JoystickLogo.png",
              name: "Joystick Mode",
              onTap: () {
                Get.to(() => JoystickModeScreen(channel: widget.channel));
              }),
          ModeBox(
              isPadded: true,
              desc:
                  "Point your phone towards screen and move the cursor by tilting your phone",
              img: "assets/PointerLogo.png",
              name: "Pointer Mode",
              onTap: () {
                Get.to(() => PointerModeScreen(channel: widget.channel));
              }),
          ModeBox(
              isPadded: true,
              desc:
                  "Point your phone towards screen and move the cursor by tilting your phone",
              img: "assets/PointerLogo.png",
              name: "Presentation Mode",
              onTap: () {
                Get.to(() => PresentationModeScreen(channel: widget.channel));
              }),
          // ListTile(
          //   title: Text('Presentation Mode'),
          //   onTap: () => Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (_) => PointerMovementScreen(
          //         channel: channel,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class ModeBox extends StatefulWidget {
  final String name;
  final String desc;
  final String img;
  final bool isPadded;
  final GestureTapCallback onTap;
  const ModeBox(
      {super.key,
      required this.isPadded,
      required this.desc,
      required this.img,
      required this.name,
      required this.onTap});

  @override
  State<ModeBox> createState() => _ModeBoxState();
}

class _ModeBoxState extends State<ModeBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          width: Get.width,
          height: Get.height * 0.15,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: currentTheme.primaryColor, blurRadius: 10),
              ],
              color: currentTheme.cardColor,
              border: Border.all(color: currentTheme.primaryColor),
              borderRadius: BorderRadius.circular(10),
              shape: BoxShape.rectangle),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return ShaderMask(
                    shaderCallback: (bounds) {
                      return RadialGradient(
                        center: Alignment.center,
                        radius: 0 + (_controller.value * 1),
                        colors: [
                          currentTheme.primaryColor,
                          currentTheme.primaryColor.withOpacity(0.6),
                          currentTheme.primaryColorLight,
                        ],
                        stops: [0.0, 0.8, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcATop,
                    child: Image.asset(
                      widget.img,
                      width: Get.width * 0.27,
                      height: widget.isPadded
                          ? Get.height * 0.11
                          : Get.height * 0.15,
                    ),
                  );
                },
              ),
              SizedBox(
                width: Get.width * 0.62,
                child: Column(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                          fontSize: 19,
                          color: currentTheme.primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.desc,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 12,
                        color: currentTheme.primaryColorLight,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
