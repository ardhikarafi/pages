/*
 * Copyright (c) 2019 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';

class CameraPage extends StatefulWidget {
  final bool isFrontCamera;
  final bool isShowSwitch;
  final String from;

  const CameraPage(
      {Key key,
      this.isFrontCamera = false,
      this.isShowSwitch = true,
      this.from = "general"})
      : super(key: key);
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController controller;
  List cameras;
  int selectedCameraIdx;
  String imagePath;

  @override
  void initState() {
    super.initState();

    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras.length > 0) {
        setState(() {
          if (widget.isFrontCamera == true && cameras.length == 2) {
            selectedCameraIdx = 1;
          } else {
            selectedCameraIdx = 0;
          }
        });

        _initCameraController(cameras[selectedCameraIdx]).then((void v) {});
      } else {
        print("No camera available");
      }
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }

    controller = CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: DetailAppBarView(
          title: widget.from == "selfie"
              ? AppLocalizations.of(context).translate(LanguageKeys.takeSelfie)
              : AppLocalizations.of(context)
                  .translate(LanguageKeys.uploadIdCard),
          isCallback: true,
          callback: () {
            Navigator.pop(
              context,
              false,
            );
          },
        ),
      ),
      body: Container(
        child: SafeArea(
          child: Stack(
            children: [
              Stack(
                alignment: FractionalOffset.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: _cameraPreviewWidget(),
                      ),
                    ],
                  ),
                  // (widget.from == "id_card" || widget.from == "selfie")
                  //     ? Container(
                  //         color: PopboxColor.transparentBlackPercent80,
                  //       )
                  //     : Container(),
                  (widget.from == "id_card" || widget.from == "selfie")
                      ? Container(
                          child: Stack(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            //crossAxisAlignment: CrossAxisAlignment.center,

                            children: [
                              widget.from == "id_card"
                                  ? Stack(
                                      alignment: Alignment.topCenter,
                                      children: [
                                        Container(
                                          height: 100.0,
                                          color: PopboxColor.mdWhite1000,
                                        ),
                                        Image.asset(
                                          "assets/images/ic_camera_card_verification.png",
                                          fit: BoxFit.fitWidth,
                                          height: 100.0.h,
                                          width: 100.0.w,

                                          // color:
                                          //     PopboxColor.transparentWhitePercent10,
                                        ),
                                      ],
                                    )
                                  : Stack(
                                      children: [
                                        Container(
                                          height: 50.0,
                                          color: PopboxColor.mdWhite1000,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: 40, bottom: 40.0),
                                          child: Image.asset(
                                            "assets/images/ic_camera_head_card_placeholder.png",
                                            fit: BoxFit.cover,
                                            height: 100.0.h,
                                            width: 100.0.w,
                                          ),
                                        ),
                                      ],
                                    ),
                              Container(
                                decoration: BoxDecoration(
                                  color: PopboxColor.mdGrey350,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding:
                                    EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 4.0),
                                margin: EdgeInsets.only(
                                    top: 20.0,
                                    left: 20.0,
                                    right: 20.0,
                                    bottom: 16.0),
                                child: CustomWidget().textRegular(
                                    widget.from == "id_card"
                                        ? AppLocalizations.of(context)
                                            .translate(
                                                LanguageKeys.makeSureIdInTheBox)
                                        : AppLocalizations.of(context)
                                            .translate(LanguageKeys
                                                .makeSureFaceIdInTheBox),
                                    PopboxColor.mdGrey700,
                                    11.0.sp,
                                    TextAlign.center),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(16.0, 28.0, 16.0, 8.0),
                    color: PopboxColor.mdWhite1000,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        widget.isShowSwitch
                            ? _cameraTogglesRowWidget()
                            : Spacer(),
                        _captureControlRowWidget(context),
                        Spacer()
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Display Camera preview.
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: CameraPreview(controller),
    );
  }

  /// Display the control bar with buttons to take pictures
  Widget _captureControlRowWidget(context) {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            FloatingActionButton(
                child: Icon(Icons.camera),
                backgroundColor: Colors.blueGrey,
                onPressed: () {
                  _onCapturePressed(context);
                })
          ],
        ),
      ),
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    if (cameras == null || cameras.isEmpty) {
      return Spacer();
    }

    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: FlatButton.icon(
            onPressed: _onSwitchCamera,
            icon: Icon(_getCameraLensIcon(lensDirection)),
            label: Text(
                "${lensDirection.toString().substring(lensDirection.toString().indexOf('.') + 1)}")),
      ),
    );
  }

  IconData _getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
  }

  void _onSwitchCamera() {
    selectedCameraIdx =
        selectedCameraIdx < cameras.length - 1 ? selectedCameraIdx + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    _initCameraController(selectedCamera);
  }

  void _onCapturePressed(context) async {
    // Take the Picture in a try / catch block. If anything goes wrong,
    // catch the error.
    try {
      // Attempt to take a picture and log where it's been saved
      final path = join(
        // In this example, store the picture in the temp directory. Find
        // the temp directory using the `path_provider` plugin.
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.jpeg',
      );
      print(path);
      await controller.takePicture(path);

      // If the picture was taken, display it on a new screen
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => CameraPreviewPage(imagePath: path),
      //   ),
      // );

      Navigator.pop(context, path);
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
    print(errorText);

    print('Error: ${e.code}\n${e.description}');
  }
}
