import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:async';
import 'dart:math' as math;
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late AnimationController _starsController;
  late AnimationController _planetController;
  late AnimationController _loadingController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _backgroundOpacity;
  late Animation<double> _starsRotation;
  late Animation<double> _planetRotation;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _starsController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _planetController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Initialize animations
    _logoScale = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    ));

    _backgroundOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeIn,
    ));

    _starsRotation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _starsController,
      curve: Curves.linear,
    ));

    _planetRotation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _planetController,
      curve: Curves.linear,
    ));

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    _backgroundController.forward();
    _starsController.repeat();
    _planetController.repeat();
    _loadingController.repeat(reverse: true);
    
    await Future.delayed(const Duration(milliseconds: 500));
    _logoController.forward();
    
    // Navigate to home screen after animations
    Timer(const Duration(milliseconds: 4000), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _backgroundController.dispose();
    _starsController.dispose();
    _planetController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Color(0xFF0B1426),
              Color(0xFF051650),
              Color(0xFF000814),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated Stars Background
            AnimatedBuilder(
              animation: _starsController,
              builder: (context, child) {
                return CustomPaint(
                  painter: StarsPainter(_starsRotation.value),
                  size: Size.infinite,
                );
              },
            ),
            
            // Animated Planets
            AnimatedBuilder(
              animation: _planetController,
              builder: (context, child) {
                return CustomPaint(
                  painter: PlanetsPainter(_planetRotation.value),
                  size: Size.infinite,
                );
              },
            ),

            // Main Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  
                  // Animated logo with glow effect
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white,
                                  Colors.blue[100]!,
                                  const Color(0xFF051650),
                                ],
                                stops: const [0.0, 0.7, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                                BoxShadow(
                                  color: const Color(0xFF051650).withOpacity(0.5),
                                  blurRadius: 50,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer glow ring
                                Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                // Logo icon with professional styling
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.2),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.storefront_rounded,
                                    size: 45,
                                    color: Color(0xFF051650),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // Company name with professional typography
                  AnimatedBuilder(
                    animation: _backgroundOpacity,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _backgroundOpacity.value,
                        child: Column(
                          children: [
                            // App name with professional typography
                            AnimatedBuilder(
                              animation: _logoController,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _logoOpacity.value,
                                  child: Column(
                                    children: [
                                      // Single word brand name with elegant styling
                                      Text(
                                        'PegasFlex',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 38,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.white.withOpacity(_logoOpacity.value),
                                          letterSpacing: 4,
                                          height: 1.1,
                                          fontFamily: 'Arial',
                                          shadows: [
                                            Shadow(
                                              color: Colors.white.withOpacity(0.4 * _logoOpacity.value),
                                              offset: const Offset(0, 1),
                                              blurRadius: 12,
                                            ),
                                            Shadow(
                                              color: const Color(0xFF051650).withOpacity(0.5 * _logoOpacity.value),
                                              offset: const Offset(0, 3),
                                              blurRadius: 15,
                                            ),
                                            Shadow(
                                              color: Colors.blue.withOpacity(0.2 * _logoOpacity.value),
                                              offset: const Offset(0, 0),
                                              blurRadius: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Elegant underline with gradient
                                      Container(
                                        width: 100,
                                        height: 1.5,
                                        margin: const EdgeInsets.only(top: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(0.75),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              Colors.white.withOpacity(0.6 * _logoOpacity.value),
                                              Colors.blue.withOpacity(0.3 * _logoOpacity.value),
                                              Colors.white.withOpacity(0.6 * _logoOpacity.value),
                                              Colors.transparent,
                                            ],
                                            stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.2 * _logoOpacity.value),
                                              blurRadius: 6,
                                              spreadRadius: 0.5,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            
                      
                            
                            
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 100),
              
              // Animated loading dots
              AnimatedBuilder(
                animation: _loadingAnimation,
                builder: (context, child) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          double delay = index * 0.3;
                          double animValue = (_loadingAnimation.value - delay).clamp(0.0, 1.0);
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Transform.scale(
                              scale: 0.5 + (math.sin(animValue * math.pi) * 0.5),
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.5 + (math.sin(animValue * math.pi) * 0.5)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 16,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Professional company attribution below loading indicator
                      AnimatedBuilder(
                        animation: _backgroundOpacity,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _backgroundOpacity.value * 0.8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.05),
                                    Colors.white.withOpacity(0.02),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.1),
                                          blurRadius: 4,
                                          spreadRadius: 0.5,
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/Pegas_Logo.ico',
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.cover,
                                        color: Colors.white.withOpacity(0.8),
                                        colorBlendMode: BlendMode.modulate,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Powered by ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.7),
                                            letterSpacing: 1,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Pegas (Pvt) Ltd',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.9),
                                            letterSpacing: 1,
                                            fontWeight: FontWeight.w700,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
      ),
    );
  }
}

// Custom painter for animated stars
class StarsPainter extends CustomPainter {
  final double rotation;
  
  StarsPainter(this.rotation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw multiple layers of stars with different sizes and opacities
    for (int layer = 0; layer < 3; layer++) {
      final layerOpacity = 0.3 + (layer * 0.2);
      final layerSize = 1.0 + (layer * 0.5);
      
      for (int i = 0; i < 50; i++) {
        final angle = (i * 2 * math.pi / 50) + (rotation * (layer + 1) * 0.1);
        final distance = 100 + (layer * 80) + (i % 20) * 10;
        
        final x = center.dx + math.cos(angle) * distance;
        final y = center.dy + math.sin(angle) * distance;
        
        if (x >= 0 && x <= size.width && y >= 0 && y <= size.height) {
          paint.color = Colors.white.withOpacity(layerOpacity * (0.5 + (i % 3) * 0.25));
          canvas.drawCircle(Offset(x, y), 1.5 * layerSize, paint);
          
          // Add twinkling effect
          if ((rotation * 10 + i) % 30 < 2) {
            paint.color = Colors.white.withOpacity(layerOpacity * 0.8);
            canvas.drawCircle(Offset(x, y), 3 * layerSize, paint);
          }
        }
      }
    }
  }
  
  @override
  bool shouldRepaint(StarsPainter oldDelegate) => oldDelegate.rotation != rotation;
}

// Custom painter for animated planets
class PlanetsPainter extends CustomPainter {
  final double rotation;
  
  PlanetsPainter(this.rotation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw orbiting planets
    for (int i = 0; i < 3; i++) {
      final angle = rotation + (i * 2 * math.pi / 3);
      final distance = 200 + (i * 60);
      final planetSize = 8.0 + (i * 3);
      
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;
      
      if (x >= 0 && x <= size.width && y >= 0 && y <= size.height) {
        final planetPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.blue.withOpacity(0.6),
              Colors.purple.withOpacity(0.3),
            ],
          ).createShader(Rect.fromCircle(center: Offset(x, y), radius: planetSize));
        
        canvas.drawCircle(Offset(x, y), planetSize, planetPaint);
        
        // Add planet glow
        final glowPaint = Paint()
          ..color = Colors.blue.withOpacity(0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
        
        canvas.drawCircle(Offset(x, y), planetSize * 2, glowPaint);
      }
    }
  }
  
  @override
  bool shouldRepaint(PlanetsPainter oldDelegate) => oldDelegate.rotation != rotation;
}
