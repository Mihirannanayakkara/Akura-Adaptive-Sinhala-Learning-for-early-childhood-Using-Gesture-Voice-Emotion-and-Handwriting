import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraPreviewWidget extends StatelessWidget {
  const CameraPreviewWidget({super.key, this.width = 140, this.height = 180});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: const [
              BoxShadow(
                blurRadius: 12,
                spreadRadius: 2,
                color: Colors.black26,
              ),
            ],
          ),
          child: const _MyCameraView(),
        ),
      ),
    );
  }
}

class _MyCameraView extends StatefulWidget {
  const _MyCameraView({super.key});

  @override
  State<_MyCameraView> createState() => _MyCameraViewState();
}

class _MyCameraViewState extends State<_MyCameraView> {
  final Map<String, dynamic> creationParams = <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? AndroidView(
            viewType: 'cameraView',
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
          )
        : const Placeholder();
  }
}
