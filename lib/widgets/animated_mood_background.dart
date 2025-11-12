import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/mood_result.dart';

/// Animated gradient background that responds to detected mood
class AnimatedMoodBackground extends StatefulWidget {
  final MoodLabel mood;
  final Widget child;

  const AnimatedMoodBackground({
    super.key,
    required this.mood,
    required this.child,
  });

  @override
  State<AnimatedMoodBackground> createState() => _AnimatedMoodBackgroundState();
}

class _AnimatedMoodBackgroundState extends State<AnimatedMoodBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getMoodGradient(widget.mood),
              stops: [
                0.0,
                0.5 + math.sin(_controller.value * 2 * math.pi) * 0.1,
                1.0,
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }

  List<Color> _getMoodGradient(MoodLabel mood) {
    switch (mood) {
      case MoodLabel.cozy:
        return [
          const Color(0xFFD4A373),
          const Color(0xFFC08552),
          const Color(0xFFA86F3D),
        ];
      case MoodLabel.energetic:
        return [
          const Color(0xFFFF6B6B),
          const Color(0xFFFF8E53),
          const Color(0xFFFFA07A),
        ];
      case MoodLabel.melancholic:
        return [
          const Color(0xFF4A5899),
          const Color(0xFF5D6AA8),
          const Color(0xFF6B7DB8),
        ];
      case MoodLabel.calm:
        return [
          const Color(0xFF95E1D3),
          const Color(0xFFAAE8DC),
          const Color(0xFFC1F0E5),
        ];
      case MoodLabel.nostalgic:
        return [
          const Color(0xFFE8A87C),
          const Color(0xFFEDB88B),
          const Color(0xFFF2C79A),
        ];
      case MoodLabel.romantic:
        return [
          const Color(0xFFE85D75),
          const Color(0xFFED7A8D),
          const Color(0xFFF297A5),
        ];
    }
  }
}

/// Floating particles animation for mood backgrounds
class MoodParticles extends StatefulWidget {
  final MoodLabel mood;

  const MoodParticles({super.key, required this.mood});

  @override
  State<MoodParticles> createState() => _MoodParticlesState();
}

class _MoodParticlesState extends State<MoodParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Generate particles
    final random = math.Random();
    for (int i = 0; i < 30; i++) {
      _particles.add(
        Particle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 4 + 2,
          speed: random.nextDouble() * 0.5 + 0.2,
          opacity: random.nextDouble() * 0.3 + 0.1,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            color: Colors.white,
          ),
          child: Container(),
        );
      },
    );
  }
}

class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final Color color;

  ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final y = ((particle.y + progress * particle.speed) % 1.0) * size.height;
      final x = particle.x * size.width;

      paint.color = color.withValues(alpha: particle.opacity);
      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
