import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:visiontxt/features/face_mesh_detector/painter/face_mesh_detector_painter.dart';
import 'package:visiontxt/widgets/detector_view.dart';

class FaceMeshDetectorView extends StatefulWidget {
  const FaceMeshDetectorView({super.key});

  @override
  State<FaceMeshDetectorView> createState() => _FaceMeshDetectorViewState();
}

class _FaceMeshDetectorViewState extends State<FaceMeshDetectorView> {
  final FaceMeshDetector _meshDetector = FaceMeshDetector(option: FaceMeshDetectorOptions.faceMesh);
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;
  List<FaceMesh> _detectedMeshes = [];

  @override
  void dispose() {
    _canProcess = false;
    _meshDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade600, Colors.orange.shade800],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.construction, size: 80, color: Colors.white),
                SizedBox(height: 24),
                Text('Under Construction', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 16),
                Text('Not implemented yet for iOS :(\nTry Android', textAlign: TextAlign.center, 
                     style: TextStyle(fontSize: 16, color: Colors.white70)),
              ],
            ),
          ),
        ),
      );
    }

    final safeArea = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          // Top App Bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: safeArea.top + 16, left: 20, right: 20, bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.orange.shade600, Colors.orange.shade800]),
              boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.grid_3x3_rounded, color: Colors.white, size: 28),
                        SizedBox(width: 12),
                        Text('MeshVision', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text('3D Face Mesh Detection', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
                InkWell(
                  onTap: () => setState(() => _cameraLensDirection = _cameraLensDirection == CameraLensDirection.back 
                      ? CameraLensDirection.front : CameraLensDirection.back),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ),

          // Main Camera View
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: Offset(0, 8))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    DetectorView(
                      title: 'Face Mesh Detector',
                      customPaint: _customPaint,
                      text: _text,
                      onImage: _processImage,
                      initialCameraLensDirection: _cameraLensDirection,
                      onCameraLensDirectionChanged: (value) => setState(() => _cameraLensDirection = value),
                    ),
                    if (_isBusy)
                      Container(
                        color: Colors.black54,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)),
                              SizedBox(height: 16),
                              Text('Analyzing Face Mesh...', style: TextStyle(color: Colors.white, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Results Panel
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.grid_on, color: Colors.green.shade600, size: 24),
                      SizedBox(width: 12),
                      Text('Mesh Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      Spacer(),
                      if (_detectedMeshes.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('${_detectedMeshes.length} Mesh${_detectedMeshes.length == 1 ? '' : 'es'}',
                              style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: SingleChildScrollView(
                        child: _detectedMeshes.isNotEmpty
                            ? Column(
                                children: _detectedMeshes.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  FaceMesh mesh = entry.value;
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 12),
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.orange.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 24, height: 24,
                                              decoration: BoxDecoration(color: Colors.orange.shade600, shape: BoxShape.circle),
                                              child: Center(child: Text('${index + 1}', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                                            ),
                                            SizedBox(width: 12),
                                            Text('Face Mesh ${index + 1}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.orange.shade700)),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text('Points: ${mesh.points.length}', style: TextStyle(fontSize: 14, color: Colors.black87)),
                                        Text('Triangles: ${mesh.triangles.length}', style: TextStyle(fontSize: 14, color: Colors.black87)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.grid_off, color: Colors.grey.shade400, size: 48),
                                    SizedBox(height: 12),
                                    Text('No face mesh detected', style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontStyle: FontStyle.italic)),
                                    Text('Point camera at a face', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: safeArea.bottom + 16),
        ],
      ),
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess || _isBusy) return;
    _isBusy = true;
    setState(() => _text = '');
    try {
      final meshes = await _meshDetector.processImage(inputImage);
      _detectedMeshes = meshes;
      if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
        _customPaint = CustomPaint(painter: FaceMeshDetectorPainter(meshes, inputImage.metadata!.size, inputImage.metadata!.rotation, _cameraLensDirection));
      } else {
        String text = 'Face meshes found: ${meshes.length}\n\n';
        for (final mesh in meshes) {
          text += 'face: ${mesh.boundingBox}\n\n';
        }
        _text = text;
        _customPaint = null;
      }
    } catch (e) {
      _text = 'Error processing image';
      _detectedMeshes = [];
    }
    _isBusy = false;
    if (mounted) setState(() {});
  }
}