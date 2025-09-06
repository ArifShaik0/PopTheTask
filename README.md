# Floating Bubbles Tasks

A fun and interactive Flutter mobile app where tasks float around as colorful bubbles on your screen!

## Features

- **Add Tasks**: Create tasks with custom titles and time estimates
- **Floating Bubbles**: Each task appears as a colorful bubble that floats around the screen
- **Countdown Timer**: Each bubble shows a live countdown timer that ticks down to zero
- **Auto-Destruction**: Bubbles automatically disappear when time runs out (task failed)
- **Interactive Popping**: Tap bubbles to mark tasks as complete before time runs out
- **Visual Feedback**: Bubbles change color as time runs low (green → orange → red)
- **Progress Ring**: Each bubble shows a circular progress indicator
- **Celebration Effects**: Enjoy confetti animations, sound effects, and congratulatory messages when completing tasks
- **Sound Feedback**: System sounds play for task completion (success) and failure
- **Daily Dashboard**: Track your daily task completion statistics
- **Weekly Overview**: See your performance over the past week
- **Success Rate Tracking**: Monitor your task completion percentage
- **Beautiful UI**: Gradient backgrounds and smooth animations

## How to Use

1. **Add a Task**: Tap the + button to create a new task
2. **Enter Details**: Provide a task title and estimated time in minutes
3. **Watch it Float**: Your task appears as a floating bubble with a countdown timer
4. **Race Against Time**: Complete your task before the timer reaches zero
5. **Complete Tasks**: Tap any bubble to mark the task as complete and enjoy the celebration!
6. **Track Progress**: Tap the dashboard icon to view your daily and weekly statistics
7. **Monitor Performance**: See how many tasks you complete vs. how many time out

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio or VS Code with Flutter extensions
- Android device or emulator

### Installation

1. Clone or download this project
2. Navigate to the project directory
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/
│   └── task.dart          # Task data model
├── screens/
│   └── home_screen.dart   # Main screen with floating bubbles
└── widgets/
    ├── floating_bubble.dart    # Individual floating bubble widget
    └── add_task_dialog.dart   # Dialog for adding new tasks
```

## Dependencies

- `flutter`: Core Flutter framework
- `confetti`: For celebration animations when tasks are completed
- `shared_preferences`: For persistent storage of daily statistics
- `cupertino_icons`: iOS-style icons

## Sound Effects

The app uses Flutter's built-in system sounds:
- **Success Sound**: Double-click sound when completing tasks
- **Failure Sound**: System alert sound when tasks time out

## Features in Detail

### Floating Animation
- Bubbles move around the screen with realistic physics
- Bounce off screen edges
- Gentle floating motion with smooth animations

### Timer System
- Live countdown timer displayed on each bubble
- Color-coded urgency system (green → orange → red)
- Circular progress ring showing time remaining
- Automatic bubble destruction when time expires

### Visual Design
- Colorful gradient bubbles with different colors for each task
- Beautiful background gradients
- Smooth shadows and visual effects
- Responsive design for different screen sizes
- Dynamic color changes based on remaining time

### User Experience
- Intuitive tap-to-complete interaction
- Immediate visual feedback
- Celebration animations with confetti (fixed to work for all completions including last task)
- Sound effects for success and failure events
- Task counter to track active tasks
- Empty state guidance for new users
- Comprehensive dashboard with statistics

### Statistics & Analytics
- Daily task completion tracking
- Success rate calculations
- Weekly performance overview
- Historical data for the past 7 days
- Persistent storage of statistics

Enjoy managing your tasks in a fun, visual way! 🎈✨