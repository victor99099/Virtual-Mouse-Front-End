import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'QRScanner.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
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
    return Scaffold(
      backgroundColor: currentTheme.canvasColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(top: Get.height * 0.1, bottom: 10),
          child: Column(
            spacing: Get.height * 0.05,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          currentTheme.primaryColor.withOpacity(0.5),
                          currentTheme.primaryColor.withOpacity(0.1),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcATop,
                    child: Image.asset(
                      "assets/mouseLogo.png",
                      width: Get.width * 0.7,
                      height: Get.height * 0.3,
                    ),
                  );
                },
              ),
              
              Text(
                "Wellcome To Virtual Mouse",
                style: TextStyle(
                    fontSize: 24,
                    color: currentTheme.primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              // SizedBox(),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(currentTheme.cardColor),
                      elevation: WidgetStatePropertyAll(10),
                      shadowColor: WidgetStatePropertyAll(currentTheme.primaryColor),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: currentTheme.primaryColor, width: 2)))),
                  onPressed: () async {
                    // await requestCameraPermission();
                    Get.to(() => QRScannerScreen());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Tap to connect",
                      style: TextStyle(
                          fontSize: 18,
                          color: currentTheme.primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                  )),
              Spacer(),
              Text(
                "Powered By Wahab",
                style: TextStyle(
                    fontSize: 14,
                    color: currentTheme.primaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
