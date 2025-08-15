import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:visiontxt/core/utils/utils.dart';
import 'package:visiontxt/features/object_detector/painter/object_detector_painter.dart';
import 'package:visiontxt/widgets/detector_view.dart';

class ObjectDetectorView extends StatefulWidget {
  const ObjectDetectorView({super.key});

  @override
  State<ObjectDetectorView> createState() => _ObjectDetectorView();
}

class _ObjectDetectorView extends State<ObjectDetectorView>
    with TickerProviderStateMixin {
  ObjectDetector? _objectDetector;
  DetectionMode _mode = DetectionMode.stream;
  bool _canProcess = false;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;
  int _option = 0;
  List<DetectedObject> _detectedObjects = [];
  
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final _options = {
    'Default Model': '',
    'Custom Objects': 'object_labeler.tflite',
    'Fruits': 'object_labeler_fruits.tflite',
    'Flowers': 'object_labeler_flowers.tflite',
    'Birds': 'lite-model_aiy_vision_classifier_birds_V1_3.tflite',
    'Food': 'lite-model_aiy_vision_classifier_food_V1_1.tflite',
    'Plants': 'lite-model_aiy_vision_classifier_plants_V1_3.tflite',
    'Mushrooms': 'lite-model_models_mushroom-identification_v1_1.tflite',
    'Landmarks': 'lite-model_on_device_vision_classifier_landmarks_classifier_north_america_V1_1.tflite',
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _slideController.forward();
  }

  @override
  void dispose() {
    _canProcess = false;
    _objectDetector?.close();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding;
    
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          // Top App Bar
          _buildTopAppBar(safeArea),
          
          // Main Camera View
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    DetectorView(
                      title: 'Object Detector',
                      customPaint: _customPaint,
                      text: _text,
                      onImage: _processImage,
                      initialCameraLensDirection: _cameraLensDirection,
                      onCameraLensDirectionChanged: (value) =>
                          setState(() => _cameraLensDirection = value),
                      onCameraFeedReady: _initializeDetector,
                      initialDetectionMode: DetectorViewMode.values[_mode.index],
                      onDetectorViewModeChanged: _onScreenModeChanged,
                    ),
                    
                    if (_isBusy)
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Detecting Objects...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Model Selection Panel
          _buildModelSelectionPanel(),
          
          const SizedBox(height: 16),
          
          // Results Panel
          _buildResultsPanel(),
          
          SizedBox(height: safeArea.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(EdgeInsets safeArea) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: safeArea.top + 16,
          left: 20,
          right: 20,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade600, Colors.teal.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.view_in_ar_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'ObjectVision',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                Text(
                  'AI Object Detection & Classification',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildStatsChip('Objects: ${_detectedObjects.length}', Icons.category),
                const SizedBox(width: 12),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _switchCamera,
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.flip_camera_ios_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelSelectionPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.model_training_rounded,
                color: Colors.teal.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Detection Model',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _option,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey.shade600,
                ),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (int? option) {
                  if (option != null) {
                    setState(() {
                      _option = option;
                      _initializeDetector();
                    });
                  }
                },
                items: List<int>.generate(_options.length, (i) => i)
                    .map<DropdownMenuItem<int>>((option) {
                  return DropdownMenuItem<int>(
                    value: option,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _option == option 
                                ? Colors.teal.shade600 
                                : Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(_options.keys.toList()[option]),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsPanel() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: Colors.green.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Detection Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                if (_detectedObjects.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_detectedObjects.length} Found',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: SingleChildScrollView(
                  child: _detectedObjects.isNotEmpty
                      ? _buildObjectsList()
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                color: Colors.grey.shade400,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No objects detected',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Point camera at objects to detect',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectsList() {
    return Column(
      children: _detectedObjects.asMap().entries.map((entry) {
        int index = entry.key;
        DetectedObject object = entry.value;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.teal.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      object.labels.isNotEmpty 
                          ? object.labels.first.text 
                          : 'Unknown Object',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              if (object.labels.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Confidence: ${(object.labels.first.confidence * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
              if (object.trackingId != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Tracking ID: ${object.trackingId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  void _switchCamera() {
    setState(() {
      _cameraLensDirection = _cameraLensDirection == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;
    });
  }

  void _onScreenModeChanged(DetectorViewMode mode) {
    switch (mode) {
      case DetectorViewMode.gallery:
        _mode = DetectionMode.single;
        _initializeDetector();
        return;
      case DetectorViewMode.liveFeed:
        _mode = DetectionMode.stream;
        _initializeDetector();
        return;
    }
  }

  void _initializeDetector() async {
    _objectDetector?.close();
    _objectDetector = null;
    log('Set detector in mode: $_mode');

    if (_option == 0) {
      log('use the default model');
      final options = ObjectDetectorOptions(
        mode: _mode,
        classifyObjects: true,
        multipleObjects: true,
      );
      _objectDetector = ObjectDetector(options: options);
    } else if (_option > 0 && _option < _options.length) {
      final option = _options[_options.keys.toList()[_option]] ?? '';
      final modelPath = await getAssetPath('assets/ml/$option');
      log('use custom model path: $modelPath');
      final options = LocalObjectDetectorOptions(
        mode: _mode,
        modelPath: modelPath,
        classifyObjects: true,
        multipleObjects: true,
      );
      _objectDetector = ObjectDetector(options: options);
    }

    _canProcess = true;
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (_objectDetector == null || !_canProcess || _isBusy) return;
    _isBusy = true;
    setState(() => _text = '');
    
    try {
      final objects = await _objectDetector!.processImage(inputImage);
      _detectedObjects = objects;
      
      if (inputImage.metadata?.size != null &&
          inputImage.metadata?.rotation != null) {
        final painter = ObjectDetectorPainter(
          objects,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        _customPaint = CustomPaint(painter: painter);
      } else {
        String text = 'Objects found: ${objects.length}\n\n';
        for (final object in objects) {
          text += 'Object: trackingId: ${object.trackingId} - ${object.labels.map((e) => e.text)}\n\n';
        }
        _text = text;
        _customPaint = null;
      }
    } catch (e) {
      _text = 'Error processing image';
      _detectedObjects = [];
    }
    
    _isBusy = false;
    if (mounted) setState(() {});
  }
}