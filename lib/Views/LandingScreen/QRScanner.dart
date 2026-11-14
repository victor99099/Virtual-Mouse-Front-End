import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../Controllers/Ads.dart';
import '../MainScreen/MainScreen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final List<TextEditingController> ipControllers =
      List.generate(4, (_) => TextEditingController());
  WebSocketChannel? channel;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var ctrl in ipControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _scanQRCode() async {
    try {
      var result = await BarcodeScanner.scan();

      if (result.rawContent.isNotEmpty) {
        _onDetect(result.rawContent);
      }
    } catch (e) {
      print("Scan error: $e");
      Get.snackbar("Error", "Failed to scan QR code");
    }
  }

  void _onDetect(String code) async {
    print("QR Code Detected: $code");

    if (isConnected) return;

    try {
      InterstitialAdManager interstitialAdManager = InterstitialAdManager();
      interstitialAdManager.loadAd();
      EasyLoading.show();
      channel = WebSocketChannel.connect(Uri.parse(code));

      Get.off(() => MainControlScreen(channel: channel!));
      setState(() {
        isConnected = true;
      });
      Future.delayed(Duration(seconds: 2), () {
        interstitialAdManager.showAd(() {});
      });
    } catch (e) {
      Get.snackbar("Error", "Invalid QR code or connection failed");
    } finally {
      EasyLoading.dismiss();
    }
  }

  bool isThrottled = false;

  void _connectManually() async {
    if (isThrottled) return;
    InterstitialAdManager interstitialAdManager = InterstitialAdManager();
    interstitialAdManager.loadAd();
    isThrottled = true;
    Future.delayed(Duration(seconds: 2), () {
      isThrottled = false;
    });
    String ipAddress = ipControllers.map((c) => c.text).join('.').trim();
    print(ipAddress);
    for (int i = 0; i < ipControllers.length; i++) {
      if (ipControllers[i].text.isEmpty) {
        Get.snackbar("Error", "Please fill all IP address fields");
        return;
      }
    }

    try {
      EasyLoading.show();
      channel = WebSocketChannel.connect(Uri.parse("ws://$ipAddress:8080"));
      channel!.stream.listen(
        (message) {
          print("Connection successful: $message");
          interstitialAdManager.showAd(() {});

          setState(() {
            isConnected = true;
          });
          Get.off(() => MainControlScreen(channel: channel!));
        },
      );
      Future.delayed(Duration(milliseconds: 1200), () {
        if (isConnected == false) {
          Get.snackbar("Error", "Invalid IP address or connection failed");
        }
      });
    } catch (e) {
      Get.snackbar("Error", "Invalid IP address or connection failed");
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(color: currentTheme.primaryColor),
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: true,
          title: Text(
            'Scan or Enter IP Manually',
            style: TextStyle(
                fontSize: 20,
                color: currentTheme.primaryColor,
                fontWeight: FontWeight.bold),
          )),
      body: SizedBox(
        width: Get.width,
        height: Get.height,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Icon(
                Icons.qr_code_scanner,
                size: 100,
                color: currentTheme.primaryColor,
              ),
              SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _scanQRCode,
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(currentTheme.cardColor),
                      elevation: WidgetStatePropertyAll(4),
                      shadowColor:
                          WidgetStatePropertyAll(currentTheme.primaryColor),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                              color: currentTheme.primaryColor, width: 2)))),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt,
                            color: currentTheme.primaryColor),
                        SizedBox(width: 8),
                        Text(
                          "Scan QR Code",
                          style: TextStyle(
                              fontSize: 18, color: currentTheme.primaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "OR",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    useSafeArea: true,
                    builder: (context) => DraggableScrollableSheet(
                      initialChildSize: 1,
                      builder: (context, scrollController) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Enter IP",
                              style: TextStyle(
                                fontSize: 24,
                                color: currentTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text("Enter IP address shown on desktop app:"),
                            SizedBox(height: 16),
                            Wrap(
                                alignment: WrapAlignment.start,
                                spacing: Get.width * 0.01,
                                runSpacing: Get.height * 0.01,
                                crossAxisAlignment: WrapCrossAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: SizedBox(
                                      width: Get.width * 0.25,
                                      child: TextField(
                                        controller: ipControllers[0],
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color:
                                                      currentTheme.primaryColor,
                                                  width: 2)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          hintText: "0-255",
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    ".",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: SizedBox(
                                      width: Get.width * 0.25,
                                      child: TextField(
                                        controller: ipControllers[1],
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color:
                                                      currentTheme.primaryColor,
                                                  width: 2)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          hintText: "0-255",
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    ".",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: SizedBox(
                                      width: Get.width * 0.25,
                                      child: TextField(
                                        controller: ipControllers[2],
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color:
                                                      currentTheme.primaryColor,
                                                  width: 2)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          hintText: "0-255",
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    ".",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: SizedBox(
                                      width: Get.width * 0.25,
                                      child: TextField(
                                        controller: ipControllers[3],
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color:
                                                      currentTheme.primaryColor,
                                                  width: 2)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          hintText: "0-255",
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ]),
                            SizedBox(height: 16),
                            ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                      currentTheme.cardColor),
                                  elevation: WidgetStatePropertyAll(4),
                                  shadowColor: WidgetStatePropertyAll(
                                      currentTheme.primaryColor),
                                  shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          side: BorderSide(
                                              color: currentTheme.primaryColor,
                                              width: 2)))),
                              onPressed: () {
                                _connectManually();
                              },
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    "Connect",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: currentTheme.primaryColor),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(currentTheme.cardColor),
                    elevation: WidgetStatePropertyAll(4),
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                            color: currentTheme.primaryColor, width: 1)))),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Enter IP Address Manually",
                    style: TextStyle(
                      fontSize: 16,
                      color: currentTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              Spacer(),
              // Network info at bottom
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: currentTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: currentTheme.primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: currentTheme.primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Make sure your desktop and mobile are connected to the same WiFi or cellular network",
                        style: TextStyle(
                          fontSize: 13,
                          color: currentTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// import '../../Controllers/Ads.dart';
// import '../MainScreen/MainScreen.dart';

// class QRScannerScreen extends StatefulWidget {
//   const QRScannerScreen({super.key});

//   @override
//   _QRScannerScreenState createState() => _QRScannerScreenState();
// }

// class _QRScannerScreenState extends State<QRScannerScreen> {
//   final List<TextEditingController> ipControllers =
//       List.generate(4, (_) => TextEditingController());
//   WebSocketChannel? channel;
//   final MobileScannerController controller = MobileScannerController();
//   bool isConnected = false;

//   @override
//   void initState() {
//     super.initState();
//     controller.start();
//     // controller.detectionSpeed = ;
//   }

//   @override
//   void dispose() {
//     controller.stop();
//     super.dispose();
//   }

//   void _onDetect(BarcodeCapture barcodeCapture) async {
//     final String code = barcodeCapture.barcodes.first.rawValue ?? '---';
//     print("QR Code Detected: $code");
    // InterstitialAdManager interstitialAdManager = InterstitialAdManager();
    // interstitialAdManager.loadAd();

//     // If connection is already attempted, return early
//     if (isConnected) return;

//     // Show loading indicator

//     try {
//       EasyLoading.show();
//       // Attempt to connect to the WebSocket
//       channel = WebSocketChannel.connect(Uri.parse(code));

//       Get.off(() => MainControlScreen(channel: channel!));
//       setState(() {
//         isConnected = true; // Mark connection as successful
//       });
//       Future.delayed(Duration(seconds: 2), () {
//         // interstitialAdManager.showAd(() {
//         // });
//       });
//     } catch (e) {
//       Get.snackbar("Error", "Invalid QR code or connection failed");
//     } finally {
//       EasyLoading.dismiss();
//     }
//   }

//   bool isThrottled = false;

//   void _connectManually() async {
//     if (isThrottled) return;
//     isThrottled = true;
//     Future.delayed(Duration(seconds: 2), () {
//       isThrottled = false;
//     });
//     String ipAddress = ipControllers.map((c) => c.text).join('.').trim();
//     print(ipAddress);
//     for (int i = 0; i < ipControllers.length; i++) {
//       if (ipControllers[i].text.isEmpty) {
//         Get.snackbar("Error", "Please fill all IP address fields");
//         return;
//       }
//     }

//     try {
//       EasyLoading.show();
//       channel = WebSocketChannel.connect(Uri.parse("ws://$ipAddress:8080"));
//       channel!.stream.listen(
//         (message) {
//           print("Connection successful: $message");
//           setState(() {
//             isConnected = true;
//           });
//           Get.off(() => MainControlScreen(channel: channel!));
//         },
//       );
//       Future.delayed(Duration(milliseconds: 1200), () {
//         if (isConnected == false) {
//           Get.snackbar("Error", "Invalid IP address or connection failed");
//         }
//       });
//     } catch (e) {
//       Get.snackbar("Error", "Invalid IP address or connection failed");
//     } finally {
//       EasyLoading.dismiss();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentTheme = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(
//           iconTheme: IconThemeData(color: currentTheme.primaryColor),
//           elevation: 0,
//           backgroundColor: Colors.transparent,
//           automaticallyImplyLeading: true,
//           title: Text(
//             'Scan or Enter IP Manually',
//             style: TextStyle(
//                 fontSize: 20,
//                 color: currentTheme.primaryColor,
//                 fontWeight: FontWeight.bold),
//           )),
//       body: SizedBox(
//         width: Get.width,
//         height: Get.height,
//         child: Column(
//           children: [
//             Flexible(
//               flex: 4,
//               child: SizedBox(
//                 height: Get.height,
//                 child: Stack(
//                   children: [
//                     MobileScanner(
//                       controller: controller,
//                       onDetect: _onDetect,
//                     ),
//                     Positioned(
//                         top: Get.width * 0.4,
//                         left: Get.width * 0.2,
//                         child: Container(
//                           width: Get.width * 0.6,
//                           height: Get.height * 0.3,
//                           decoration: BoxDecoration(
//                               // boxShadow: [
//                               //   BoxShadow(
//                               //       color: currentTheme.primaryColor,
//                               //       blurRadius: 10),
//                               // ],
//                               color: Colors.transparent,
//                               border: Border.all(
//                                   color: currentTheme.primaryColor, width: 3),
//                               borderRadius: BorderRadius.circular(10),
//                               shape: BoxShape.rectangle),
//                         ))
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(
//               width: Get.width,
//               height: Get.height * 0.1,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: ElevatedButton(
//                   onPressed: () {
//                     showModalBottomSheet(
//                       context: context,
//                       isScrollControlled: true,
//                       showDragHandle: true,
//                       useSafeArea: true,
//                       // barrierColor: currentTheme.primaryColor,
//                       builder: (context) => DraggableScrollableSheet(
//                         initialChildSize: 1,
//                         // minChildSize: 0.7,
//                         // maxChildSize: 0.7,
//                         builder: (context, scrollController) => Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Enter IP",
//                                 style: TextStyle(
//                                   fontSize: 24,
//                                   color: currentTheme.primaryColor,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: 8),
//                               Text("Enter IP address shown on desktop app:"),
//                               SizedBox(height: 16),
//                               Wrap(
//                                   alignment: WrapAlignment.start,
//                                   spacing: Get.width * 0.01,
//                                   runSpacing: Get.height * 0.01,
//                                   crossAxisAlignment: WrapCrossAlignment.end,
//                                   // mainAxisAlignment:
//                                   //     MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 4.0),
//                                       child: SizedBox(
//                                         width: Get.width * 0.25,
//                                         child: TextField(
//                                           controller: ipControllers[0],
//                                           keyboardType: TextInputType.number,
//                                           decoration: InputDecoration(
//                                             focusedBorder: OutlineInputBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(10),
//                                                 borderSide: BorderSide(
//                                                     color: currentTheme
//                                                         .primaryColor,
//                                                     width: 2)),
//                                             border: OutlineInputBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(10)),
//                                             hintText: "0-255",
//                                           ),
//                                           textAlign: TextAlign.center,
//                                           // maxLength: 3,
//                                         ),
//                                       ),
//                                     ),
//                                     Text(
//                                       ".",
//                                       style: TextStyle(
//                                           fontSize: 20,
//                                           color: Colors.grey,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 4.0),
//                                       child: SizedBox(
//                                         width: Get.width * 0.25,
//                                         child: TextField(
//                                           controller: ipControllers[1],
//                                           keyboardType: TextInputType.number,
//                                           decoration: InputDecoration(
//                                             focusedBorder: OutlineInputBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(10),
//                                                 borderSide: BorderSide(
//                                                     color: currentTheme
//                                                         .primaryColor,
//                                                     width: 2)),
//                                             border: OutlineInputBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(10)),
//                                             hintText: "0-255",
//                                           ),
//                                           textAlign: TextAlign.center,
//                                           // maxLength: 3,
//                                         ),
//                                       ),
//                                     ),
//                                     Text(
//                                       ".",
//                                       style: TextStyle(
//                                           fontSize: 20,
//                                           color: Colors.grey,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 4.0),
//                                       child: SizedBox(
//                                         width: Get.width * 0.25,
//                                         child: TextField(
//                                           controller: ipControllers[2],
//                                           keyboardType: TextInputType.number,
//                                           decoration: InputDecoration(
//                                             focusedBorder: OutlineInputBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(10),
//                                                 borderSide: BorderSide(
//                                                     color: currentTheme
//                                                         .primaryColor,
//                                                     width: 2)),
//                                             border: OutlineInputBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(10)),
//                                             hintText: "0-255",
//                                           ),
//                                           textAlign: TextAlign.center,
//                                           // maxLength: 3,
//                                         ),
//                                       ),
//                                     ),
//                                     Text(
//                                       ".",
//                                       style: TextStyle(
//                                           fontSize: 20,
//                                           color: Colors.grey,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 4.0),
//                                       child: SizedBox(
//                                         width: Get.width * 0.25,
//                                         child: TextField(
//                                           controller: ipControllers[3],
//                                           keyboardType: TextInputType.number,
//                                           decoration: InputDecoration(
//                                             focusedBorder: OutlineInputBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(10),
//                                                 borderSide: BorderSide(
//                                                     color: currentTheme
//                                                         .primaryColor,
//                                                     width: 2)),
//                                             border: OutlineInputBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(10)),
//                                             hintText: "0-255",
//                                           ),
//                                           textAlign: TextAlign.center,
//                                           // maxLength: 3,
//                                         ),
//                                       ),
//                                     ),
//                                   ]),
//                               SizedBox(height: 16),
//                               ElevatedButton(
//                                 style: ButtonStyle(
//                                     backgroundColor: WidgetStatePropertyAll(
//                                         currentTheme.cardColor),
//                                     elevation: WidgetStatePropertyAll(4),
//                                     shadowColor: WidgetStatePropertyAll(
//                                         currentTheme.primaryColor),
//                                     shape: WidgetStatePropertyAll(
//                                         RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(10),
//                                             side: BorderSide(
//                                                 color:
//                                                     currentTheme.primaryColor,
//                                                 width: 2)))),
//                                 onPressed: () {
//                                   _connectManually();
//                                 },
//                                 child: Center(
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(16.0),
//                                     child: Text(
//                                       "Connect",
//                                       style: TextStyle(
//                                           fontSize: 18,
//                                           color: currentTheme.primaryColor),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                   style: ButtonStyle(
//                       backgroundColor:
//                           WidgetStatePropertyAll(currentTheme.cardColor),
//                       elevation: WidgetStatePropertyAll(4),
//                       // shadowColor:
//                       //     WidgetStatePropertyAll(currentTheme.primaryColor),
//                       shape: WidgetStatePropertyAll(RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           side: BorderSide(
//                               color: currentTheme.primaryColor, width: 1)))),
//                   child: Text(
//                     "Or Enter Ip Address",
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: currentTheme.primaryColor,
//                     ),
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
