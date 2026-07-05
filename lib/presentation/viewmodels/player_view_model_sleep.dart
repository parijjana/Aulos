import 'dart:async';
import 'player_view_model.dart';

extension PlayerViewModelSleep on PlayerViewModel {
  void startSleepTimer(Duration duration) {
    cancelSleepTimer();
    sleepDurationTotal = duration;
    sleepTimerEndTime = DateTime.now().add(duration);
    isSleepTimerActive = true;
    
    countdownTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      triggerNotify();
    });
    
    sleepTimer = Timer(duration, () {
      startSleepFadeOut();
    });
    triggerNotify();
  }

  void startSleepFadeOut() {
    countdownTicker?.cancel();
    countdownTicker = null;
    
    final double startVolume = volume;
    const fadeSteps = 30;
    const fadeStepDuration = Duration(milliseconds: 1000); // 30 seconds total fade out
    int currentStep = 0;
    
    sleepFadeTimer = Timer.periodic(fadeStepDuration, (timer) {
      currentStep++;
      final double nextVolume = startVolume * (1.0 - (currentStep / fadeSteps));
      if (nextVolume <= 0.0 || currentStep >= fadeSteps) {
        timer.cancel();
        pause();
        setVolume(startVolume); // Restore original volume for when they resume playing later
        isSleepTimerActive = false;
        sleepTimerEndTime = null;
        sleepDurationTotal = null;
      } else {
        engine.setVolume(nextVolume);
      }
      triggerNotify();
    });
  }

  void cancelSleepTimer() {
    sleepTimer?.cancel();
    sleepTimer = null;
    sleepFadeTimer?.cancel();
    sleepFadeTimer = null;
    countdownTicker?.cancel();
    countdownTicker = null;
    
    if (isSleepTimerActive) {
      isSleepTimerActive = false;
      engine.setVolume(volume); // Restore volume
      sleepTimerEndTime = null;
      sleepDurationTotal = null;
    }
    triggerNotify();
  }
}
