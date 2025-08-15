import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visiontxt/core/utils/app_icons_images.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
              Colors.teal.shade50,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header Section
              _buildHeader(safeArea),

              // Features Grid
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildFeaturesSection(),
                ),
              ),

              // Footer Section
              _buildFooter(),

              SizedBox(height: safeArea.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(EdgeInsets safeArea) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: safeArea.top,
        left: 24,
        right: 24,
        bottom: 15,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF010332), // Extremely dark blue
            Color(
              0xFF29011C,
            ), // Nearly black purple// Regal vivid purple/ Violet-blue
          ], // Orbit End],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 10),
          // Subtitle
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Google ML-Kit Package Integration',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats Row
          FadeTransition(
            opacity: _fadeAnimation,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatChip('6 Features', Icons.extension),
                _buildStatChip('AI Powered', Icons.psychology),
                _buildStatChip('Real-time', Icons.speed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
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

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Features',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Explore powerful machine learning capabilities',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
          
          // Features Grid
          _buildEnhancedGrid(),
        ],
      ),
    );
  }

  Widget _buildEnhancedGrid() {
    final mlKitFeatures = [
      {
        'label': 'Text Recognition',
        'description': 'Extract text from images',
        'icon': AppIcons.ocrIcon,

        'onTap': () => _handleTextRecognition(),
      },
      {
        'label': 'Face Detection',
        'description': 'Detect and analyze faces',
        'icon': AppIcons.faceDetectIcon,

        'onTap': () => _handleFaceDetection(),
      },
      {
        'label': 'Face Mesh',
        'description': '3D face mesh analysis',
        'icon': AppIcons.meshIcon,

        'onTap': () => _handleFaceMeshDetection(),
      },
      {
        'label': 'Object Detection',
        'description': 'Identify objects in real-time',
        'icon': AppIcons.objectDetectIcon,

        'onTap': () => _handleObjectDetection(),
      },
      {
        'label': 'Pose Detection',
        'description': 'Human pose estimation',
        'icon': AppIcons.poseDetectionIcon,

        'onTap': () => _poshDetection(),
      },
      {
        'label': 'Selfie Segmentation',
        'description': 'Background separation',
        'icon': AppIcons.selfieIcon,

        'onTap': () => _selfieSegmentDetection(),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
        }
        if (constraints.maxWidth > 900) {
          crossAxisCount = 4;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: mlKitFeatures.length,
          itemBuilder: (context, index) {
            final feature = mlKitFeatures[index];
            return _buildFeatureCard(feature, index);
          },
        );
      },
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + (index * 200)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (0.5 * value),
          child: Opacity(
            opacity: value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: feature['onTap'] as VoidCallback,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF232526), // Charcoal
                        Color(0xFF3A41C6), // Violet-blue
                        Color(0xFF512888), // Deep purple
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(blurRadius: 15, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Image.asset(
                          feature['icon'] as String,
                          width: 30,
                          height: 30,

                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported,

                              size: 30,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        feature['label'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          feature['description'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Powered by Google ML Kit',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Experience the power of on-device machine learning',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void _handleTextRecognition() => context.go('/txt');
  void _handleFaceDetection() => context.go('/face');
  void _handleFaceMeshDetection() => context.go('/mesh');
  void _handleObjectDetection() => context.go('/object');
  void _poshDetection() => context.go('/pds');
  void _selfieSegmentDetection() => context.go('/segment');
}
