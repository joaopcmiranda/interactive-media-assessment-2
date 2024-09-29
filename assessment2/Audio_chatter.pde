import beads.*;
import java.io.File;

class SoundController {
  AudioContext ac;
  Gain gain;
  SamplePlayer chatterPlayer;
  float maxCO2Level = 2000.0; // Maximum expected CO2 level to normalize volume
  float targetVolume = 0; // Target volume to interpolate towards
  float currentVolume = 0; // Current volume level

  SoundController() {
    ac = new AudioContext();
    
    // Load the chattering sound file
    try {
      Sample chatterSample = new Sample(sketchPath("chattering-crowd-73725.mp3"));
      chatterPlayer = new SamplePlayer(ac, chatterSample);
      chatterPlayer.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS); // Loop the sound
    } catch (Exception e) {
      e.printStackTrace();
    }

    // Set up gain control (starts with 0 volume)
    gain = new Gain(ac, 1, 0);
    gain.addInput(chatterPlayer);
    ac.out.addInput(gain);
    ac.start();
  }

  // Update volume based on CO2 level
  void updateVolume(float co2Level) {
    // Normalize CO2 level and map to target volume (0.0 to 1.0)
    targetVolume = map(co2Level, 0, maxCO2Level, 0.0, 1.0);
  }

  // Call this in the draw loop to gradually change the volume
  void smoothVolume() {
    // Interpolate current volume towards target volume
    currentVolume += (targetVolume - currentVolume) * 0.1; // Adjust the factor for smoothness
    gain.setGain(currentVolume);
  }
}
