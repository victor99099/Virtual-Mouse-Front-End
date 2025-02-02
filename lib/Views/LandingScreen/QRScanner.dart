import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../MainScreen/MainScreen.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  WebSocketChannel? channel = WebSocketChannel.connect(Uri.parse("ws://192.168.18.8:8080/"));
  // WebSocketChannel? channel;
  final MobileScannerController controller = MobileScannerController();
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    controller.start();
    // controller.detectionSpeed = ;
  }

  @override
  void dispose() {
    controller.stop();
    super.dispose();
  }

  void _onDetect(BarcodeCapture barcodeCapture) async {
    final String code = barcodeCapture.barcodes.first.rawValue ?? '---';
    print("QR Code Detected: $code");

    // If connection is already attempted, return early
    if (isConnected) return;

    // Show loading indicator

    try {
      EasyLoading.show();
      // Attempt to connect to the WebSocket
      channel = WebSocketChannel.connect(Uri.parse(code));

      Get.off(() => MainControlScreen(channel: channel!));
      setState(() {
        isConnected = true; // Mark connection as successful
      });
    } catch (e) {
      Get.snackbar("Error", "Invalid QR code or connection failed");
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return
        // appBar: AppBar(title: Text('Scan QR Code')),
        MainControlScreen(channel: channel!);
    //     MobileScanner(
    //   controller: controller,
    //   onDetect: _onDetect,
    // );
  }
}
