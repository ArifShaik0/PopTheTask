import 'dart:math';
import 'package:flutter/material.dart';
import 'package:floating_bubbles_tasks/models/task.dart';

class BubbleData {
  final Task task;
  double x;
  double y;
  double dx;
  double dy;
  final double radius;
  final VoidCallback onPop;
  final VoidCallback onTimeUp;

  BubbleData({
    required this.task,
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.radius,
    required this.onPop,
    required this.onTimeUp,
  });
}

class BubblePhysicsService {
  static const double minSpeed = 0.8;
  static const double maxSpeed = 2.5;
  static const double dampening = 0.98; // Slight energy loss on collision
  
  final Size screenSize;
  final double topBoundary;
  final double bottomBoundary;
  final List<BubbleData> bubbles = [];
  final Random _random = Random();

  BubblePhysicsService({
    required this.screenSize,
    this.topBoundary = 0,
    this.bottomBoundary = 0,
  });

  void addBubble(BubbleData bubble) {
    // Ensure speed is within range
    final speed = sqrt(bubble.dx * bubble.dx + bubble.dy * bubble.dy);
    if (speed < minSpeed || speed > maxSpeed) {
      final newSpeed = minSpeed + _random.nextDouble() * (maxSpeed - minSpeed);
      final angle = atan2(bubble.dy, bubble.dx);
      bubble.dx = cos(angle) * newSpeed;
      bubble.dy = sin(angle) * newSpeed;
    }
    
    bubbles.add(bubble);
  }

  void removeBubble(String taskId) {
    bubbles.removeWhere((bubble) => bubble.task.id == taskId);
  }

  void updatePhysics() {
    // Update positions
    for (final bubble in bubbles) {
      bubble.x += bubble.dx;
      bubble.y += bubble.dy;
      
      // Bounce off walls
      if (bubble.x <= bubble.radius || bubble.x >= screenSize.width - bubble.radius) {
        bubble.dx = -bubble.dx;
        bubble.x = bubble.x.clamp(bubble.radius, screenSize.width - bubble.radius);
      }
      if (bubble.y <= topBoundary + bubble.radius || bubble.y >= screenSize.height - bottomBoundary - bubble.radius) {
        bubble.dy = -bubble.dy;
        bubble.y = bubble.y.clamp(topBoundary + bubble.radius, screenSize.height - bottomBoundary - bubble.radius);
      }
    }
    
    // Check for bubble collisions
    for (int i = 0; i < bubbles.length; i++) {
      for (int j = i + 1; j < bubbles.length; j++) {
        _checkCollision(bubbles[i], bubbles[j]);
      }
    }
  }

  void _checkCollision(BubbleData bubble1, BubbleData bubble2) {
    final dx = bubble2.x - bubble1.x;
    final dy = bubble2.y - bubble1.y;
    final distance = sqrt(dx * dx + dy * dy);
    final minDistance = bubble1.radius + bubble2.radius;
    
    if (distance < minDistance && distance > 0) {
      // Collision detected - calculate bounce
      final overlap = minDistance - distance;
      final separationX = (dx / distance) * (overlap / 2);
      final separationY = (dy / distance) * (overlap / 2);
      
      // Separate bubbles
      bubble1.x -= separationX;
      bubble1.y -= separationY;
      bubble2.x += separationX;
      bubble2.y += separationY;
      
      // Calculate new velocities (elastic collision)
      final normalX = dx / distance;
      final normalY = dy / distance;
      
      // Relative velocity in collision normal direction
      final relativeVelocityX = bubble2.dx - bubble1.dx;
      final relativeVelocityY = bubble2.dy - bubble1.dy;
      final speed = relativeVelocityX * normalX + relativeVelocityY * normalY;
      
      // Do not resolve if velocities are separating
      if (speed > 0) return;
      
      // Apply dampening
      final dampedSpeed = speed * dampening;
      
      // Update velocities
      bubble1.dx += dampedSpeed * normalX;
      bubble1.dy += dampedSpeed * normalY;
      bubble2.dx -= dampedSpeed * normalX;
      bubble2.dy -= dampedSpeed * normalY;
      
      // Ensure speeds stay within bounds after collision
      _regulateSpeed(bubble1);
      _regulateSpeed(bubble2);
    }
  }

  void _regulateSpeed(BubbleData bubble) {
    final speed = sqrt(bubble.dx * bubble.dx + bubble.dy * bubble.dy);
    
    if (speed < minSpeed) {
      final factor = minSpeed / speed;
      bubble.dx *= factor;
      bubble.dy *= factor;
    } else if (speed > maxSpeed) {
      final factor = maxSpeed / speed;
      bubble.dx *= factor;
      bubble.dy *= factor;
    }
  }

  BubbleData? getBubbleByTaskId(String taskId) {
    try {
      return bubbles.firstWhere((bubble) => bubble.task.id == taskId);
    } catch (e) {
      return null;
    }
  }
}