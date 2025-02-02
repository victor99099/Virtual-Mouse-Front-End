import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SensitivitySheet extends StatefulWidget {
  final RxDouble sensitivity;
  final double min;
  final double max;
  final int divisions;
  const SensitivitySheet(
      {super.key,
      required this.divisions,
      required this.sensitivity,
      required this.min,
      required this.max});

  @override
  State<SensitivitySheet> createState() => _SensitivitySheetState();
}

class _SensitivitySheetState extends State<SensitivitySheet> {
  RxDouble _bottomSheetHeight =
      30.0.obs; // Initial height (showing only handle)
  RxBool _isExpanded = false.obs;

  void _toggleBottomSheet() {
    if (_isExpanded.value) {
      _bottomSheetHeight.value = 30; // Collapse to show only handle
    } else {
      _bottomSheetHeight.value =
          Get.height * 0.17; // Expand to show full content
    }
    _isExpanded.value = !_isExpanded.value;
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return Obx(
      () => AnimatedContainer(
        curve: Curves.bounceOut,
        duration: Duration(milliseconds: 200),
        height: _bottomSheetHeight.value,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(color: currentTheme.primaryColor, blurRadius: 10),
            ],
            color: currentTheme.cardColor,
            // border: Border.all(color: currentTheme.primaryColor),
            border: Border(
                top: BorderSide(color: currentTheme.primaryColor),
                left: BorderSide(color: currentTheme.primaryColor),
                right: BorderSide(color: currentTheme.primaryColor)),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            shape: BoxShape.rectangle),
        child: Column(
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                    width: Get.width * 0.2,
                    height: 5,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        color: currentTheme.primaryColor,
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ),
                IgnorePointer(
                  ignoring: false,
                  child: GestureDetector(
                    onVerticalDragStart: (details) => _toggleBottomSheet(),
                    // onVerticalDragUpdate: (details) => _toggleBottomSheet(),
                    onTap: () {
                      _toggleBottomSheet();
                    },
                    child: Container(
                      width: Get.width,
                      height: 29,
                      color: Colors.transparent,
                      // margin: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
                child: _isExpanded.value
                    ? Container(
                        height: _bottomSheetHeight.value,
                        child: Column(
                          children: [
                            Text("Adjust Sensitivty"),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: Get.width * 0.05,
                                  child: Text("${widget.sensitivity.value.toStringAsFixed(0)}")),
                                SizedBox(
                                  width: Get.width * 0.7,
                                  child: Slider(
                                    inactiveColor: const Color.fromARGB(255, 70, 69, 69),
                                    activeColor: currentTheme.primaryColor,
                                      thumbColor: currentTheme.primaryColor,
                                      min: widget.min,
                                      max: widget.max,
                                      // divisions: widget.divisions,
                                      value: widget.sensitivity.value,
                                      onChanged: (newValue) {
                                        widget.sensitivity.value = newValue;
                                      }),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Container())
          ],
        ),
      ),
    );
  }
}
class JoyStickSensitivitySheet extends StatefulWidget {
  final RxDouble sensitivity;
  final double min;
  final double max;
  final int divisions;
  const JoyStickSensitivitySheet(
      {super.key,
      required this.divisions,
      required this.sensitivity,
      required this.min,
      required this.max});

  @override
  State<JoyStickSensitivitySheet> createState() => _JoyStickSensitivitySheetState();
}

class _JoyStickSensitivitySheetState extends State<JoyStickSensitivitySheet> {
  RxDouble _bottomSheetWidth =
      30.0.obs; // Initial height (showing only handle)
  RxBool _isExpanded = false.obs;

  void _toggleBottomSheet() {
    if (_isExpanded.value) {
      _bottomSheetWidth.value = 30; // Collapse to show only handle
    } else {
      _bottomSheetWidth.value =
          Get.width * 0.3; // Expand to show full content
    }
    _isExpanded.value = !_isExpanded.value;
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return Obx(
      () => AnimatedContainer(
        curve: Curves.bounceOut,
        duration: Duration(milliseconds: 200),
        width: _bottomSheetWidth.value,
        height: Get.height * 0.25,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(color: currentTheme.primaryColor, blurRadius: 10),
            ],
            color: currentTheme.cardColor,
            // border: Border.all(color: currentTheme.primaryColor),
            border: Border(
                top: BorderSide(color: currentTheme.primaryColor),
                left: BorderSide(color: currentTheme.primaryColor),
                bottom: BorderSide(color: currentTheme.primaryColor)),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
            shape: BoxShape.rectangle),
        child: Row(
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                    width: 5,
                    height: 20,
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        color: currentTheme.primaryColor,
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ),
                IgnorePointer(
                  ignoring: false,
                  child: GestureDetector(
                    onVerticalDragStart: (details) => _toggleBottomSheet(),
                    // onVerticalDragUpdate: (details) => _toggleBottomSheet(),
                    onTap: () {
                      _toggleBottomSheet();
                    },
                    child: Container(
                      width: 29,
                      height: Get.height * 0.25,
                      color: Colors.transparent,
                      // margin: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
                child: _isExpanded.value
                    ? Container(
                        width: _bottomSheetWidth.value,
                        child: Column(
                          children: [
                            Text("Adjust Sensitivty"),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: Get.width * 0.025,
                                  child: Text("${widget.sensitivity.value.toStringAsFixed(0)}")),
                                SizedBox(
                                  width: Get.width * 0.2,
                                  child: Slider(
                                    inactiveColor: const Color.fromARGB(255, 70, 69, 69),
                                    activeColor: currentTheme.primaryColor,
                                      thumbColor: currentTheme.primaryColor,
                                      min: widget.min,
                                      max: widget.max,
                                      // divisions: widget.divisions,
                                      value: widget.sensitivity.value,
                                      onChanged: (newValue) {
                                        widget.sensitivity.value = newValue;
                                      }),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Container())
          ],
        ),
      ),
    );
  }
}
