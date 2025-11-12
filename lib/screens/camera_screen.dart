import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

import '../services/camera_service.dart';
import '../services/model_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  final _cameraService = CameraService.instance;
  final _modelService = ModelService.instance;

  bool _isInitializing = true;
  bool _isProcessing = false;
  String? _error;
  FlashMode _flashMode = FlashMode.auto;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraService.controller;

    // App state changed before we got the chance to initialize
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeServices();
    }
  }

  Future<void> _initializeServices() async {
    setState(() {
      _isInitializing = true;
      _error = null;
    });

    try {
      // Initialize camera
      if (!_cameraService.isInitialized) {
        await _cameraService.initialize();
      }

      // Initialize model
      if (!_modelService.isInitialized) {
        await _modelService.initialize();
      }

      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isInitializing = false;
      });
    }
  }

  Future<void> _takePictureAndAnalyze() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Take picture
      final imagePath = await _cameraService.takePicture();

      // Run inference
      final result = await _modelService.predictMood(imagePath);

      // Navigate to results
      if (mounted) {
        await Navigator.pushNamed(
          context,
          '/results',
          arguments: result,
        );
      }

      // Clean up temporary file
      try {
        await File(imagePath).delete();
      } catch (_) {}
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await _cameraService.switchCamera();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error switching camera: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _toggleFlash() async {
    FlashMode newMode;
    switch (_flashMode) {
      case FlashMode.off:
        newMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        newMode = FlashMode.always;
        break;
      case FlashMode.always:
      case FlashMode.torch:
        newMode = FlashMode.off;
        break;
    }

    await _cameraService.setFlashMode(newMode);
    setState(() {
      _flashMode = newMode;
    });
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
      case FlashMode.torch:
        return Icons.flash_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _buildError();
    }

    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final controller = _cameraService.controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: Text(
          'Camera not available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        _buildCameraPreview(controller),

        // Top bar
        _buildTopBar(),

        // Bottom controls
        _buildBottomControls(),

        // Processing overlay
        if (_isProcessing) _buildProcessingOverlay(),
      ],
    );
  }

  Widget _buildCameraPreview(CameraController controller) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    final previewRatio = controller.value.aspectRatio;

    return Transform.scale(
      scale: deviceRatio / previewRatio,
      child: Center(
        child: CameraPreview(controller),
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.6),
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // App title with gradient
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFF1DB954),
                    Color(0xFF1ED760),
                  ],
                ).createShader(bounds),
                child: const Text(
                  'VibeLens',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),

              // Flash toggle with animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.history),
                          color: Colors.white,
                          iconSize: 28,
                          onPressed: () =>
                              Navigator.pushNamed(context, '/history'),
                          tooltip: 'Mood History',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: Icon(_getFlashIcon()),
                          color: Colors.white,
                          iconSize: 28,
                          onPressed: _toggleFlash,
                          tooltip: 'Flash',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Switch camera button
                AnimatedOpacity(
                  opacity: _isProcessing ? 0.3 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.flip_camera_ios),
                      color: Colors.white,
                      iconSize: 32,
                      onPressed: _isProcessing ? null : _switchCamera,
                    ),
                  ),
                ),

                // Capture button with pulse animation
                GestureDetector(
                  onTap: _isProcessing ? null : _takePictureAndAnalyze,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: _isProcessing ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 1.0 - (value * 0.1),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: value * 5,
                              ),
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isProcessing
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : Colors.white,
                            ),
                            child: _isProcessing
                                ? const Center(
                                    child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Color(0xFF1DB954),
                                        ),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Settings button
                AnimatedOpacity(
                  opacity: _isProcessing ? 0.3 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune),
                      color: Colors.white,
                      iconSize: 32,
                      onPressed: _isProcessing
                          ? null
                          : () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Analyzing mood...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Camera Error',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeServices,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
