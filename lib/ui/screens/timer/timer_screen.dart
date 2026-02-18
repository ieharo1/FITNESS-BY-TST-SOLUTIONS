import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../theme/app_theme.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _selectedDuration = 60;
  int _remainingSeconds = 60;
  Timer? _timer;
  bool _isRunning = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<int> _durations = [30, 60, 90, 120, 180];

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;
    
    setState(() {
      _isRunning = true;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _playAlarm();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _selectedDuration;
      _isRunning = false;
    });
  }

  void _setDuration(int seconds) {
    _timer?.cancel();
    setState(() {
      _selectedDuration = seconds;
      _remainingSeconds = seconds;
      _isRunning = false;
    });
  }

  void _playAlarm() async {
    HapticFeedback.heavyImpact();
    
    for (int i = 0; i < 3; i++) {
      await HapticFeedback.vibrate();
      await Future.delayed(const Duration(milliseconds: 200));
    }
    
    try {
      await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      try {
        await _audioPlayer.play(UrlSource('https://www.soundjay.com/buttons/beep-01a.mp3'));
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      } catch (e2) {
        debugPrint('Error playing sound: $e2');
      }
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Descanso completado!'),
        content: const Text('Es hora de volver al entrenamiento.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              _audioPlayer.stop();
              Navigator.pop(context);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temporizador'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          _buildDurationSelector(),
          const SizedBox(height: 40),
          _buildTimerDisplay(),
          const SizedBox(height: 40),
          _buildControls(),
          const Spacer(),
          _buildQuickButtons(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Duración del descanso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _durations.map((d) => ChoiceChip(
                label: Text('${d}s'),
                selected: _selectedDuration == d,
                onSelected: _isRunning ? null : (_) => _setDuration(d),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerDisplay() {
    final progress = _remainingSeconds / _selectedDuration;
    final color = _remainingSeconds <= 10 ? Colors.red : AppTheme.primaryColor;

    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 250,
            height: 250,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatTime(_remainingSeconds),
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                _isRunning ? 'Descansando...' : 'Listo',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          heroTag: 'reset',
          onPressed: _resetTimer,
          backgroundColor: Colors.grey.shade300,
          child: const Icon(Icons.refresh),
        ),
        const SizedBox(width: 24),
        FloatingActionButton.large(
          heroTag: 'play',
          onPressed: _isRunning ? _pauseTimer : _startTimer,
          backgroundColor: _isRunning ? Colors.orange : AppTheme.primaryColor,
          child: Icon(_isRunning ? Icons.pause : Icons.play_arrow, size: 36),
        ),
        const SizedBox(width: 24),
        FloatingActionButton(
          heroTag: 'add',
          onPressed: () => _setDuration(_remainingSeconds + 30),
          backgroundColor: Colors.grey.shade300,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _buildQuickButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const Text('Tiempos rápidos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickButton(30, Icons.coffee),
              _buildQuickButton(60, Icons.timer),
              _buildQuickButton(90, Icons.hourglass_bottom),
              _buildQuickButton(120, Icons.snooze),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(int seconds, IconData icon) {
    return InkWell(
      onTap: () => _setDuration(seconds),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(height: 4),
            Text('${seconds}s', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
