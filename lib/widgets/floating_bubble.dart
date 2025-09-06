import 'dart:async';
import 'package:flutter/material.dart';
import 'package:floating_bubbles_tasks/models/task.dart';
import 'package:floating_bubbles_tasks/services/bubble_physics_service.dart';
import 'package:floating_bubbles_tasks/widgets/task_completion_dialog.dart';

class FloatingBubble extends StatefulWidget {
  final Task task;
  final VoidCallback onPop;
  final VoidCallback onTimeUp;
  final BubblePhysicsService physicsService;
  final double x;
  final double y;

  const FloatingBubble({
    super.key,
    required this.task,
    required this.onPop,
    required this.onTimeUp,
    required this.physicsService,
    required this.x,
    required this.y,
  });

  @override
  State<FloatingBubble> createState() => _FloatingBubbleState();
}

class _FloatingBubbleState extends State<FloatingBubble>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _popController;
  late Animation<Offset> _floatingAnimation;
  late Animation<double> _scaleAnimation;
  
  late Timer _countdownTimer;
  late Task _currentTask;

  @override
  void initState() {
    super.initState();
    
    _currentTask = widget.task;
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _popController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _floatingAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.1),
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _popController,
      curve: Curves.elasticIn,
    ));
    
    // Start countdown timer
    _startCountdown();
  }



  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTask.remainingSeconds--;
        });
        
        if (_currentTask.remainingSeconds <= 0) {
          timer.cancel();
          _destroyBubble();
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _popBubble() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must choose yes or no
      builder: (context) => TaskCompletionDialog(task: widget.task),
    );
    
    // Only proceed if user confirmed completion
    if (confirmed == true) {
      _countdownTimer.cancel();
      await _popController.forward();
      widget.onPop();
    }
    // If user said no or dismissed dialog, bubble continues floating
  }

  void _destroyBubble() async {
    _countdownTimer.cancel();
    await _popController.forward();
    widget.onTimeUp();
  }

  Color _getBubbleColor() {
    final colors = [
      Colors.pink.shade300,
      Colors.blue.shade300,
      Colors.green.shade300,
      Colors.orange.shade300,
      Colors.purple.shade300,
      Colors.teal.shade300,
    ];
    
    final baseColor = colors[widget.task.id.hashCode % colors.length];
    
    // Change color based on remaining time
    final progress = _currentTask.progressPercentage;
    if (progress < 0.2) {
      return Colors.red.shade400; // Critical time
    } else if (progress < 0.5) {
      return Colors.orange.shade400; // Warning time
    }
    
    return baseColor;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.x - 60, // Center the bubble (radius = 60)
      top: widget.y - 60,
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatingAnimation, _scaleAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value == 0 ? 1.0 : _scaleAnimation.value,
            child: Transform.translate(
              offset: _floatingAnimation.value * 20,
              child: GestureDetector(
                onTap: _popBubble,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getBubbleColor(),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    gradient: RadialGradient(
                      colors: [
                        _getBubbleColor().withValues(alpha: 0.8),
                        _getBubbleColor(),
                      ],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Progress ring
                      Positioned.fill(
                        child: CircularProgressIndicator(
                          value: _currentTask.progressPercentage,
                          strokeWidth: 4,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      // Content
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.task.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _currentTask.formattedTime,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    _floatingController.dispose();
    _popController.dispose();
    super.dispose();
  }
}