import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:floating_bubbles_tasks/models/task.dart';
import 'package:floating_bubbles_tasks/widgets/floating_bubble.dart';
import 'package:floating_bubbles_tasks/widgets/add_task_dialog.dart';
import 'package:floating_bubbles_tasks/services/stats_service.dart';
import 'package:floating_bubbles_tasks/services/sound_service.dart';
import 'package:floating_bubbles_tasks/services/bubble_physics_service.dart';
import 'package:floating_bubbles_tasks/screens/dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> _tasks = [];
  late ConfettiController _confettiController;
  late BubblePhysicsService _physicsService;
  late Timer _physicsTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _physicsService = BubblePhysicsService(
      screenSize: Size.zero,
      topBoundary: 0,
      bottomBoundary: 0,
    ); // Will be updated in build
    
    // Start physics update loop
    _physicsTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (mounted) {
        _physicsService.updatePhysics();
        setState(() {}); // Trigger rebuild to update bubble positions
      }
    });
  }

  void _addTask() async {
    final task = await showDialog<Task>(
      context: context,
      builder: (context) => const AddTaskDialog(),
    );
    
    if (task != null) {
      setState(() {
        _tasks.add(task);
        _addBubbleToPhysics(task);
      });
    }
  }

  void _addBubbleToPhysics(Task task) {
    final screenSize = MediaQuery.of(context).size;
    final appBarHeight = AppBar().preferredSize.height + MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80; // FAB space
    
    // Update physics service screen size if needed
    if (_physicsService.screenSize != screenSize) {
      _physicsService = BubblePhysicsService(
        screenSize: screenSize,
        topBoundary: appBarHeight,
        bottomBoundary: bottomPadding,
      );
      
      // Re-add all existing bubbles except the new one
      for (final existingTask in _tasks.where((t) => t.id != task.id)) {
        final availableHeight = screenSize.height - appBarHeight - bottomPadding - 120;
        final bubbleData = BubbleData(
          task: existingTask,
          x: _random.nextDouble() * (screenSize.width - 120) + 60,
          y: appBarHeight + 60 + _random.nextDouble() * availableHeight,
          dx: (_random.nextDouble() - 0.5) * 3,
          dy: (_random.nextDouble() - 0.5) * 3,
          radius: 60,
          onPop: () => _popBubble(existingTask),
          onTimeUp: () => _onTaskTimeUp(existingTask),
        );
        _physicsService.addBubble(bubbleData);
      }
    }
    
    // Add the new bubble
    final availableHeight = screenSize.height - appBarHeight - bottomPadding - 120;
    final bubbleData = BubbleData(
      task: task,
      x: _random.nextDouble() * (screenSize.width - 120) + 60,
      y: appBarHeight + 60 + _random.nextDouble() * availableHeight,
      dx: (_random.nextDouble() - 0.5) * 3,
      dy: (_random.nextDouble() - 0.5) * 3,
      radius: 60,
      onPop: () => _popBubble(task),
      onTimeUp: () => _onTaskTimeUp(task),
    );
    _physicsService.addBubble(bubbleData);
  }

  void _popBubble(Task task) {
    // Play success sound
    SoundService.playSuccessSound();
    
    // Trigger confetti BEFORE removing the task to ensure it plays
    _confettiController.play();
    
    // Record task completion
    StatsService.recordTaskCompletion(true);
    
    // Show congratulations snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Great job completing "${task.title}"!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Remove from physics service immediately
    _physicsService.removeBubble(task.id);
    
    // Remove task after confetti duration to ensure it's fully visible
    // Confetti controller duration is 2 seconds, so wait 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _tasks.removeWhere((t) => t.id == task.id);
        });
      }
    });
  }

  void _onTaskTimeUp(Task task) {
    // Play failure sound
    SoundService.playFailureSound();
    
    // Remove from physics service
    _physicsService.removeBubble(task.id);
    
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
    });
    
    // Record task failure
    StatsService.recordTaskCompletion(false);
    
    // Show failure message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⏰ Time\'s up for "${task.title}"!'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openDashboard() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final appBarHeight = AppBar().preferredSize.height + MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80; // FAB space
    
    // Update physics service screen size if needed
    if (_physicsService.screenSize != screenSize) {
      _physicsService = BubblePhysicsService(
        screenSize: screenSize,
        topBoundary: appBarHeight,
        bottomBoundary: bottomPadding,
      );
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF), // Light blue background
      appBar: AppBar(
        title: const Text(
          'Bubble Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: _openDashboard,
            tooltip: 'Dashboard',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade100,
                  Colors.purple.shade50,
                ],
              ),
            ),
          ),
          
          // Floating bubbles
          ..._tasks.map((task) {
            final bubbleData = _physicsService.getBubbleByTaskId(task.id);
            if (bubbleData != null) {
              return FloatingBubble(
                key: ValueKey(task.id),
                task: task,
                onPop: () => _popBubble(task),
                onTimeUp: () => _onTaskTimeUp(task),
                physicsService: _physicsService,
                x: bubbleData.x,
                y: bubbleData.y,
              );
            }
            return const SizedBox.shrink();
          }),
          
          // Empty state message
          if (_tasks.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bubble_chart,
                    size: 80,
                    color: Colors.blue.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first task',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue.shade400,
                    ),
                  ),
                ],
              ),
            ),
          
          // Confetti overlay - always present and positioned to be visible
          Positioned(
            top: 50, // Below the app bar
            left: screenSize.width / 2 - 10, // Slightly offset for better spread
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // Downward
              blastDirectionality: BlastDirectionality.explosive, // Spread in all directions
              maxBlastForce: 10,
              minBlastForce: 5,
              emissionFrequency: 0.02,
              numberOfParticles: 100,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
                Colors.cyan,
                Colors.red,
              ],
            ),
          ),
          
          // Task counter
          if (_tasks.isNotEmpty)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${_tasks.length} task${_tasks.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: Colors.blue.shade400,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _physicsTimer.cancel();
    _confettiController.dispose();
    SoundService.dispose();
    super.dispose();
  }
}