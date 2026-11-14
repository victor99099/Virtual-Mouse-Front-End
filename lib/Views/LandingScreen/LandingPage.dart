import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'QRScanner.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  RxBool isChecked = true.obs;
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
            // spacing: Get.height * 0.05,
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
                      height: Get.height * 0.4,
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
              SizedBox(
                height: Get.height * 0.05,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Card(
                      shadowColor: currentTheme.primaryColor,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: currentTheme.primaryColor, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: PopupMenuButton<String>(
                          position: PopupMenuPosition.under,
                          icon: Icon(Icons.info,
                              color: currentTheme.primaryColor),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                                value: 'Item 1',
                                child: RichText(
                                    text: TextSpan(
                                        text: "Visit ",
                                        style: DefaultTextStyle.of(context)
                                            .style
                                            .copyWith(
                                                fontSize: 16,
                                                color: Colors.white),
                                        children: [
                                      TextSpan(
                                          text:
                                              'virtual-mouse-deebugs.web.app ',
                                          style: TextStyle(
                                              color:
                                                  currentTheme.primaryColor)),
                                      TextSpan(text: "to get desktop app.")
                                    ]))

                                // Text(
                                //   'Visit virtual-mouse-deebugs.web.app to get desktop app',
                                //   style: TextStyle(
                                //     fontSize: 16,
                                //     fontWeight: FontWeight.normal,
                                //     color: Colors.white,
                                //   ),
                                // )

                                ),
                          ],
                        ),
                      ),
                    ),
                    Obx(
                      () => ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                  currentTheme.cardColor),
                              elevation: WidgetStatePropertyAll(
                                  isChecked.value ? 4 : 0),
                              shadowColor: WidgetStatePropertyAll(
                                  isChecked.value
                                      ? currentTheme.primaryColor
                                      : Colors.grey),
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                          color: isChecked.value
                                              ? currentTheme.primaryColor
                                              : Colors.grey,
                                          width: 2)))),
                          onPressed: () async {
                            // await requestCameraPermission();
                            if (isChecked.value) {
                              Get.to(() => QRScannerScreen());
                            } else {
                              Get.snackbar("Info",
                                  "Please check that you have read Privacy & Policy and Terms of use");
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "Scan to connect",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: isChecked.value
                                      ? currentTheme.primaryColor
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold),
                            ),
                          )),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Get.width * 0.075,
                    right: Get.width * 0.05,
                    top: Get.width * 0.04),
                child: TermsAndPrivacyRow(
                  isChecked: isChecked,
                ),
              ),
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

class TermsAndPrivacyRow extends StatefulWidget {
  final RxBool isChecked;
  TermsAndPrivacyRow({super.key, required this.isChecked});
  @override
  _TermsAndPrivacyRowState createState() => _TermsAndPrivacyRowState();
}

class _TermsAndPrivacyRowState extends State<TermsAndPrivacyRow> {
  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: Get.width * 0.02,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: Get.width * 0.08,
          height: Get.width * 0.08,
          child: Checkbox(
            value: widget.isChecked.value,
            checkColor: Theme.of(context).cardColor,
            side: BorderSide(color: Theme.of(context).cardColor),
            fillColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
            onChanged: (value) {
              setState(() {
                widget.isChecked.value = value ?? false;
              });
            },
          ),
        ),
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              Text(
                'I agree to the ',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              GestureDetector(
                onTap: () => _launchUrl(
                    'https://virtual-mouse-deebugs.web.app/privacy-policy'),
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                ' and the ',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              GestureDetector(
                onTap: () => _launchUrl(
                    'https://virtual-mouse-deebugs.web.app/terms-of-use'),
                child: Text(
                  'Terms of Use',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
