import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Reusable scaffold that draws an animated "space" background and a
/// frosted glass overlay where the app content sits. Designed to be a
/// drop-in replacement for Scaffold where common slots (appBar, body,
/// drawer, floatingActionButton) are forwarded.
class SpaceLiquidScaffold extends StatefulWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? drawer;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Color? glassColor;

  const SpaceLiquidScaffold({
    super.key,
    this.appBar,
    this.body,
    this.drawer,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.glassColor,
  });

  @override
  State<SpaceLiquidScaffold> createState() => _SpaceLiquidScaffoldState();
}

class _SpaceLiquidScaffoldState extends State<SpaceLiquidScaffold>
    with TickerProviderStateMixin {
  late AnimationController _starsController;
  late AnimationController _nebulaController;
  late AnimationController _blobController;

  @override
  void initState() {
    super.initState();
    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _nebulaController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _starsController.dispose();
    _nebulaController.dispose();
    _blobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glass = widget.glassColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.26));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // Space background layers
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _starsController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _StarsPainter(_starsController.value * 2 * math.pi),
                  size: Size.infinite,
                );
              },
            ),
          ),

          // Nebula gradient overlay
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _nebulaController,
              builder: (context, child) {
                final t = _nebulaController.value;
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(-0.2 + t * 0.4, -0.3 + t * 0.3),
                      radius: 1.4,
                      colors: [
                        Colors.deepPurple.withValues(alpha: 0.18 + t * 0.08),
                        Colors.indigo.withValues(alpha: 0.12 + (1 - t) * 0.06),
                        Colors.blue.withValues(alpha: 0.06),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                );
              },
            ),
          ),

          // Moving soft blobs to create a liquid effect
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _blobController,
              builder: (context, child) {
                final v = _blobController.value;
                return CustomPaint(
                  painter: _BlobsPainter(v),
                  size: Size.infinite,
                );
              },
            ),
          ),

          // Use an inner transparent Scaffold to correctly host AppBar/Drawer/FAB
          // and let Flutter manage semantics and parent data.
          Positioned.fill(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              extendBody: true,
              extendBodyBehindAppBar: true,
              appBar: widget.appBar,
              drawer: widget.drawer,
              floatingActionButton: widget.floatingActionButton,
              floatingActionButtonLocation: widget.floatingActionButtonLocation,
              bottomNavigationBar: widget.bottomNavigationBar,
              body: Padding(
                padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: glass,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: widget.body ?? const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  final double rotation;
  _StarsPainter(this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final rnd = math.Random(42);
    for (int i = 0; i < 120; i++) {
      final cx = rnd.nextDouble() * size.width;
      final cy = rnd.nextDouble() * size.height;
      final w = (rnd.nextDouble() * 2.6) + (rnd.nextDouble() * 1.8);
      final opacity = 0.2 + rnd.nextDouble() * 0.8;
      paint.color = Colors.white.withValues(alpha: opacity * 0.7);
      canvas.drawCircle(Offset(cx + math.sin(rotation + i) * 2, cy + math.cos(rotation + i) * 2), w * 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) => oldDelegate.rotation != rotation;
}

class _BlobsPainter extends CustomPainter {
  final double t;
  _BlobsPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Soft purple blob
    paint.shader = RadialGradient(
      colors: [Colors.purple.withValues(alpha: 0.24), Colors.transparent],
    ).createShader(Rect.fromCircle(center: Offset(size.width * 0.2 + math.sin(t * 2.0) * 30, size.height * 0.25 + math.cos(t * 1.3) * 20), radius: 220));
    canvas.drawCircle(Offset(size.width * 0.2 + math.sin(t * 2.0) * 30, size.height * 0.25 + math.cos(t * 1.3) * 20), 220, paint);

    // Soft blue blob
    paint.shader = RadialGradient(
      colors: [Colors.blue.withValues(alpha: 0.14), Colors.transparent],
    ).createShader(Rect.fromCircle(center: Offset(size.width * 0.8 + math.cos(t * 1.6) * 40, size.height * 0.7 + math.sin(t * 1.1) * 30), radius: 260));
    canvas.drawCircle(Offset(size.width * 0.8 + math.cos(t * 1.6) * 40, size.height * 0.7 + math.sin(t * 1.1) * 30), 260, paint);

    // Soft cyan accent
    paint.shader = RadialGradient(
      colors: [Colors.cyan.withValues(alpha: 0.08), Colors.transparent],
    ).createShader(Rect.fromCircle(center: Offset(size.width * 0.5 + math.sin(t * 1.2) * 20, size.height * 0.5 + math.cos(t * 0.9) * 20), radius: 180));
    canvas.drawCircle(Offset(size.width * 0.5 + math.sin(t * 1.2) * 20, size.height * 0.5 + math.cos(t * 0.9) * 20), 180, paint);
  }

  @override
  bool shouldRepaint(covariant _BlobsPainter oldDelegate) => oldDelegate.t != t;
}
