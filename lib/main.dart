import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:virtualmousemobile/Views/LandingScreen/LandingPage.dart';

import 'utils/Themes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: MyTheme.lightTheme(context),
      darkTheme: MyTheme.darkTheme(context),
      title: 'Virtual Mouse',
      builder: EasyLoading.init(),
      home: const LandingPage(),
    );
  }
}







// Include TouchpadMode, MotionControlMode, and PointerMode screens as implemented earlier




// class MotionControlModeScreen extends StatefulWidget {
//   final WebSocketChannel channel;
//   const MotionControlModeScreen({Key? key, required this.channel})
//       : super(key: key);

//   @override
//   State<MotionControlModeScreen> createState() =>
//       _MotionControlModeScreenState();
// }

// class _MotionControlModeScreenState extends State<MotionControlModeScreen> {
//   late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

//   // Calibration offsets
//   double _offsetX = 0.0;
//   double _offsetY = 0.0;

//   // Variables to handle sensitivity, dead zone, and smoothing
//   final double sensitivity = 2.0;
//   final double deadZone = 0.1;
//   final double smoothingFactor = 0.2;

//   double _lastX = 0.0;
//   double _lastY = 0.0;

//   bool _isCalibrated = false;

//   @override
//   void initState() {
//     super.initState();

//     // Listen to accelerometer events
//     _accelerometerSubscription =
//         accelerometerEvents.listen((AccelerometerEvent event) {
//       if (!_isCalibrated) {
//         // Calibrate baseline values when the device is stationary
//         _offsetX = event.x;
//         _offsetY = event.y;
//         _isCalibrated = true;
//         return;
//       }

//       handleMotionData(event.x - _offsetX, event.y - _offsetY);
//     });
//   }

//   void handleMotionData(double rawX, double rawY) {
//     // Apply a dead zone filter
//     double dx = rawX.abs() > deadZone ? rawX : 0.0;
//     double dy = rawY.abs() > deadZone ? rawY : 0.0;

//     // Apply smoothing (low-pass filter)
//     dx = (_lastX * (1 - smoothingFactor)) + (dx * smoothingFactor);
//     dy = (_lastY * (1 - smoothingFactor)) + (dy * smoothingFactor);

//     // Update last values for smoothing
//     _lastX = dx;
//     _lastY = dy;

//     // Adjust sensitivity
//     dx *= sensitivity;
//     dy *= sensitivity;

//     // Send the adjusted motion data
//     sendMotionData(dx, dy);
//   }

//   void sendMotionData(double dx, double dy) {
//     final message = 'motion,$dx,$dy';
//     print(message);
//     widget.channel.sink.add(message);
//   }

//   @override
//   void dispose() {
//     _accelerometerSubscription.cancel();
//     widget.channel.sink.close(WebSocketStatus.normalClosure);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Motion Control Mode'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Use device motion to control the cursor.\nMotion sensors are active.',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 16),
//             ),
//             if (!_isCalibrated)
//               const Padding(
//                 padding: EdgeInsets.only(top: 20),
//                 child: Text(
//                   'Calibrating... Hold the device still.',
//                   style: TextStyle(color: Colors.red),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class PointerModeScreen extends StatefulWidget {
//   final WebSocketChannel channel;
//   const PointerModeScreen({Key? key, required this.channel}) : super(key: key);

//   @override
//   State<PointerModeScreen> createState() => _PointerModeScreenState();
// }

// class _PointerModeScreenState extends State<PointerModeScreen> {
//   late StreamSubscription<GyroscopeEvent> _gyroscopeSubscription;
//   Timer? _throttleTimer;
//   double prevX = 0;
//   double prevY = 0;
//   double initialX = 0; // Initial gyroscope reading
//   double initialY = 0; // Initial gyroscope reading

//   final double smoothingFactor = 0.2; // Smoothing factor
//   final double deadzone = 0.2; // Deadzone to ignore minor movements

//   @override
//   void initState() {
//     super.initState();
//     _startGyroscopeListener();
//   }

//   @override
//   void dispose() {
//     _gyroscopeSubscription.cancel();
//     super.dispose();
//   }

//   void _startGyroscopeListener() {
//     _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
//       if (initialX == 0 && initialY == 0) {
//         // First reading, set the initial values for neutral position
//         initialX = event.x;
//         initialY = event.y;
//         return; // Skip the first event for calibration
//       }

//       // Calculate relative movement from the initial position
//       double relativeX = event.x - initialX;
//       double relativeY = event.y - initialY;

//       // Apply smoothing
//       double smoothedX = prevX + smoothingFactor * (relativeX - prevX);
//       double smoothedY = prevY + smoothingFactor * (relativeY - prevY);

//       // Deadzone to avoid minor fluctuations from being registered
//       if (smoothedX.abs() < deadzone && smoothedY.abs() < deadzone) {
//         return; // Ignore small movements
//       }

//       // Scaling to control the cursor movement speed
//       int scaledX = (smoothedX * 100).round();
//       int scaledY = (smoothedY * 100).round();

//       // Avoid sending (0,0) position to avoid resetting cursor to the top-left
//       if (scaledX == 0 && scaledY == 0) {
//         return;
//       }

//       sendPointerMovement(scaledX, scaledY);

//       // Update previous values for next smoothing
//       prevX = smoothedX;
//       prevY = smoothedY;
//     });
//   }

//   void sendPointerMovement(int x, int y) {
//     // Use abs to convert negative values to positive values
//     final absX = x.abs().toInt();
//     final absY = y.abs().toInt();

//     // Throttling: Only send the message after a delay to prevent excessive calls
//     if (_throttleTimer?.isActive ?? false) {
//       _throttleTimer?.cancel(); // Cancel the previous timer
//     }

//     // Set a new throttle timer to send the message after a delay (e.g., 50ms)
//     _throttleTimer = Timer(Duration(milliseconds: 50), () {
//       final message = 'pointer,$absX,$absY';
//       print('Message : ---- $message');
//       widget.channel.sink.add(message); // Send data via WebSocket
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get screen dimensions dynamically
//     // if (screenWidth == 0 || screenHeight == 0) {
//     //   screenWidth = MediaQuery.of(context).size.width;
//     //   screenHeight = MediaQuery.of(context).size.height;

//     //   // Start the cursor in the center of the screen
//     //   _cursorX = screenWidth / 2;
//     //   _cursorY = screenHeight / 2;
//     // }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Pointer Mode'),
//       ),
//       body: Stack(
//         children: [
//           Container(
//             color: Colors.grey[300],
//             child: const Center(
//               child: Text(
//                 'Point your phone toward the screen and tilt it to control the cursor.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//           ),
//           // Positioned(
//           //   left: _cursorX - 15, // Center the pointer icon
//           //   top: _cursorY - 15,
//           //   child: Icon(
//           //     Icons.circle,
//           //     size: 30,
//           //     color: Colors.red,
//           //   ),
//           // ),
//           ElevatedButton(
//             onPressed: () {
//               // Button to stop the listener or any other functionality
//               _gyroscopeSubscription.cancel();
//             },
//             child: const Text('Stop Listening'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class PointerModeScreen2 extends StatefulWidget {
//   final WebSocketChannel channel;
//   const PointerModeScreen2({Key? key, required this.channel}) : super(key: key);

//   @override
//   State<PointerModeScreen2> createState() => _PointerModeScreen2State();
// }

// class _PointerModeScreen2State extends State<PointerModeScreen2> {
//   double _gyroX = 0.0;
//   double _gyroY = 0.0;
//   double _gyroZ = 0.0;

//   double _accumulatedDx = 0.0;
//   double _accumulatedDy = 0.0;

//   Timer? _throttleTimer; // Timer for throttling
//   static const double movementThresholdX =
//       0.05; // Lowered threshold for smoother motion
//   static const double movementThresholdY =
//       0.05; // Lowered threshold for smoother motion
//   static const double sensitivity = 2.3; // Sensitivity for scaling movement

//   @override
//   void initState() {
//     super.initState();

//     // Listen to gyroscope data stream
//     gyroscopeEvents.listen((GyroscopeEvent event) {
//       setState(() {
//         _gyroX = event.x;
//         _gyroY = event.y;
//         // _gyroZ = event.z ;
//       });
//       if (_gyroX.abs() > movementThresholdX && _gyroY.abs() <= 0.1) {
//         _accumulatedDx += (_gyroX);
//         // _accumulatedDy = 0;
//       } else if (_gyroY.abs() > movementThresholdY && _gyroX.abs() <= 0.1) {
//         _accumulatedDy += (_gyroY);
//       } else {
//         _accumulatedDx += (_gyroX);
//         _accumulatedDy += (_gyroY);
//       }
//       // Accumulate changes

//       if (_throttleTimer?.isActive ?? false)
//         return; // Skip if throttling is active

//       // Throttle updates to 500ms
//       _throttleTimer = Timer(const Duration(milliseconds: 10), () {
//         // Only send movement if significant enough
//         if (_accumulatedDx.abs() > movementThresholdX ||
//             _accumulatedDy.abs() > movementThresholdY) {
//           print("X : $_accumulatedDx  Y : $_accumulatedDy");

//           sendPointerMovement(_accumulatedDx, _accumulatedDy);
//           _accumulatedDx = 0.0; // Reset accumulation
//           _accumulatedDy = 0.0;
//         }
//       });
//     });
//   }

//   void sendPointerMovement(double x, double y) {
//     // Scale movements before sending
//     final scaledX = -x * sensitivity * 1.1;
//     final scaledY = y * sensitivity;

//     final message = 'pointer,$scaledY,$scaledX';
//     widget.channel.sink.add(message);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Gyroscope Example'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text('Gyroscope Data:'),
//             Text('X: $_gyroX'),
//             Text('Y: $_gyroY'),
//             Text('Z: $_gyroZ'),
//             ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _accumulatedDx = 0.0; // Reset accumulation
//                     _accumulatedDy = 0.0;
//                   });
//                   final message = 'Center';
//                   widget.channel.sink.add(message);
//                 },
//                 child: Text("Center"))
//           ],
//         ),
//       ),
//     );
//   }
// }

// void checkAccelerometerAvailability() {
//   accelerometerEvents.listen(
//     (AccelerometerEvent event) {
//       print("Accelerometer is available.");
//     },
//     onError: (error) {
//       print("Accelerometer is NOT available on this device.");
//     },
//     cancelOnError: true,
//   );
// }

// class PointerModeScreen3 extends StatefulWidget {
//   final WebSocketChannel channel;
//   const PointerModeScreen3({Key? key, required this.channel}) : super(key: key);

//   @override
//   State<PointerModeScreen3> createState() => _PointerModeScreen3State();
// }

// class _PointerModeScreen3State extends State<PointerModeScreen3> {
//   double _gyroX = 0.0;
//   double _gyroY = 0.0;

//   double _accumulatedDx = 0.0;
//   double _accumulatedDy = 0.0;

//   double lastHeading = 0.0;
//   double _filteredHeading = 0.0; // Smoothed heading value
//   final double _filterFactor =
//       0.2; // Adjust this value to control the smoothing
//   bool isFirstHeading = true;

//   Timer? _throttleTimer;
//   static const double movementThresholdX = 0.1;
//   static const double movementThresholdY = 0.7;
//   static const double sensitivity = 2.0;
//   static const double sensitivityY = 2.0;

//   @override
//   void initState() {
//     super.initState();

//     gyroscopeEvents.listen((GyroscopeEvent event) {
//       setState(() {
//         _gyroX = event.x;
//         _accumulatedDx += _gyroX;
//       });
//       _processMotion();
//     });

//     FlutterCompass.events!.listen((CompassEvent event) {
//       double? newHeading = 0.0;
//       newHeading = !isFirstHeading ? event.heading : 0.0;

//       // Apply low-pass filter to smooth the heading
//       _filteredHeading =
//           _filteredHeading + (_filterFactor * (newHeading! - _filteredHeading));

//       double delta = _filteredHeading - lastHeading;

//       setState(() {
//         // Use filtered heading change to update Y axis movement
//         if (isFirstHeading) {
//           isFirstHeading = false;
//         }
//         _accumulatedDy += delta;
//         lastHeading =
//             _filteredHeading; // Update lastHeading with filtered heading
//       });
//       _processMotion();
//     });
//   }

//   void resetCompass() {
//     setState(() {
//       _gyroY = 0.0; // Reset relative heading
//       _accumulatedDy = 0;
//       isFirstHeading = true;
//     });
//   }

//   void _processMotion() {
//     if (_throttleTimer?.isActive ?? false) return;

//     _throttleTimer = Timer(const Duration(milliseconds: 50), () {
//       if (_accumulatedDx.abs() > movementThresholdX ||
//           _accumulatedDy.abs() > movementThresholdY) {
//         sendPointerMovement(_accumulatedDx, _accumulatedDy);

//         _accumulatedDx = 0.0;
//         _accumulatedDy = 0.0;
//       }
//     });
//   }

//   void sendPointerMovement(double x, double y) {
//     final scaledX = -x * sensitivity;
//     final scaledY = y * sensitivityY;

//     final message = 'pointer,$scaledY,$scaledX';
//     widget.channel.sink.add(message);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Gyroscope Example'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text('Gyroscope Data:'),
//             Text('X: $_gyroX'),
//             Text('Y: $_gyroY'),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _accumulatedDx = 0.0;
//                   _accumulatedDy = 0.0;
//                   lastHeading = 0.0; // Reset compass reference
//                   resetCompass();
//                 });
//                 final message = 'Center';
//                 widget.channel.sink.add(message);
//               },
//               child: Text("Center"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

Future<void> requestCameraPermission() async {
  var status = await Permission.camera.request();
  if (status.isGranted) {
    // Proceed to open camera
  } else {
    // Show dialog or message explaining why the permission is needed
  }
}

// class SensorDataDisplay extends StatefulWidget {
//   @override
//   _SensorDataDisplayState createState() => _SensorDataDisplayState();
// }

// class _SensorDataDisplayState extends State<SensorDataDisplay> {
//   // Variables to store sensor data
//   AccelerometerEvent? _accelerometerEvent;
//   GyroscopeEvent? _gyroscopeEvent;
//   UserAccelerometerEvent? _userAccelerometerEvent;
//   MagnetometerEvent? _magnetometerEvent;

//   @override
//   void initState() {
//     super.initState();

//     // Listen to the accelerometer events
//     accelerometerEvents.listen((event) {
//       setState(() {
//         _accelerometerEvent = event;
//       });
//     });

//     // Listen to the gyroscope events
//     gyroscopeEvents.listen((event) {
//       setState(() {
//         _gyroscopeEvent = event;
//       });
//     });

//     // Listen to the user accelerometer events
//     userAccelerometerEvents.listen((event) {
//       setState(() {
//         _userAccelerometerEvent = event;
//       });
//     });

//     // Listen to the magnetometer events
//     magnetometerEvents.listen((event) {
//       setState(() {
//         _magnetometerEvent = event;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Sensor Data Display'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Accelerometer: ${_accelerometerEvent?.x.toStringAsFixed(2)}, '
//               '${_accelerometerEvent?.y.toStringAsFixed(2)}, '
//               '${_accelerometerEvent?.z.toStringAsFixed(2)}',
//             ),
//             SizedBox(height: 10),
//             Text(
//               'Gyroscope: ${_gyroscopeEvent?.x.toStringAsFixed(2)}, '
//               '${_gyroscopeEvent?.y.toStringAsFixed(2)}, '
//               '${_gyroscopeEvent?.z.toStringAsFixed(2)}',
//             ),
//             SizedBox(height: 10),
//             Text(
//               'User Accelerometer: ${_userAccelerometerEvent?.x.toStringAsFixed(2)}, '
//               '${_userAccelerometerEvent?.y.toStringAsFixed(2)}, '
//               '${_userAccelerometerEvent?.z.toStringAsFixed(2)}',
//             ),
//             SizedBox(height: 10),
//             Text(
//               'Magnetometer: ${_magnetometerEvent?.x.toStringAsFixed(2)}, '
//               '${_magnetometerEvent?.y.toStringAsFixed(2)}, '
//               '${_magnetometerEvent?.z.toStringAsFixed(2)}',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class CompassZAxisExample extends StatefulWidget {
//   @override
//   _CompassZAxisExampleState createState() => _CompassZAxisExampleState();
// }

// class _CompassZAxisExampleState extends State<CompassZAxisExample> {
//   double? _zAxisValue;

//   @override
//   void initState() {
//     super.initState();
//     // Listen to compass heading (yaw), which relates to the Z-axis rotation
//     FlutterCompass.events?.listen((event) {
//       setState(() {
//         _zAxisValue = event.heading; // Heading corresponds to Z-axis rotation
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Compass Z-Axis Example"),
//       ),
//       body: Center(
//         child: _zAxisValue == null
//             ? const Text("Waiting for sensor data...")
//             : Text(
//                 "Z-Axis Rotation (Heading): ${_zAxisValue!.toStringAsFixed(2)}°",
//                 style: const TextStyle(fontSize: 18),
//               ),
//       ),
//     );
//   }
// }

// class PointerMovementScreen extends StatefulWidget {
//   final WebSocketChannel channel;
//   const PointerMovementScreen({super.key, required this.channel});

//   @override
//   _PointerMovementScreenState createState() => _PointerMovementScreenState();
// }

// class _PointerMovementScreenState extends State<PointerMovementScreen> {
//   bool isCursorMovingEnabled = false;
//   double sensitivity = 5;
//   String? connectionStatus;
//   StreamSubscription? accelerometerSubscription;
//   DateTime lastMouseMovement = DateTime.now();
//   Timer? _throttleTimer;

//   @override
//   void initState() {
//     super.initState();
//   }

//   void sendMessage(String data) {
//     widget.channel.sink.add(data);
//   }

//   void sendMouseMovement(double x, double y, DateTime timestamp) {
//     print("$x . $y");
//     var seconds =
//         timestamp.difference(lastMouseMovement).inMilliseconds / (1000);
//     lastMouseMovement = timestamp;
//     print(seconds);
//     // Apply sensitivity adjustments
//     x = (x * sensitivity * seconds);
//     y = (y * sensitivity * seconds);
//     print("$x . $y");

//     const double thresholdX = 0.1;
//     const double thresholdY = 0.1;

//     if (x.abs() <= thresholdX) x = 0;
//     if (y.abs() <= thresholdY) y = 0;

//     final data = 'pointer2,$x,$y';

//     print(data);

//     if (isCursorMovingEnabled) {
//       sendMessage(data);
//     }
//   }

//   void startAccelerometerListening() {
//     accelerometerSubscription =
//         accelerometerEvents.listen((AccelerometerEvent event) {
//       if (_throttleTimer?.isActive ?? false)
//         return; // Skip if throttling is active

//       _throttleTimer = Timer(const Duration(milliseconds: 20), () {
//         // Use accelerometer X and Y for movement tracking
//         sendMouseMovement(event.x, event.y, DateTime.now());
//       });
//     });
//   }

//   void stopAccelerometerListening() {
//     accelerometerSubscription?.cancel();
//     accelerometerSubscription = null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Presentation Remote'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 10),
//               Text(
//                 'Status: ${connectionStatus ?? "Not connected"}',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//               const SizedBox(height: 20),
//               Text('Sensitivity: ${sensitivity.toStringAsFixed(2)}'),
//               Slider(
//                 value: sensitivity,
//                 min: 0.1,
//                 max: 100,
//                 onChanged: (v) {
//                   setState(() {
//                     sensitivity = v;
//                   });
//                   // sendMessage({"changeSensitivityEvent": v});
//                 },
//               ),
//               const SizedBox(height: 20),
//               Center(
//                 child: GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       isCursorMovingEnabled = !isCursorMovingEnabled;
//                     });
//                     if (isCursorMovingEnabled) {
//                       // sendMessage({"event": "MouseMotionStart"});
//                       startAccelerometerListening();
//                     } else {
//                       // sendMessage({"event": "MouseMotionStop"});
//                       stopAccelerometerListening();
//                     }
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.all(20.0),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: isCursorMovingEnabled ? Colors.green : Colors.red,
//                     ),
//                     child: Text(
//                       isCursorMovingEnabled
//                           ? 'Cursor Movement Enabled'
//                           : 'Cursor Movement Disabled',
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
