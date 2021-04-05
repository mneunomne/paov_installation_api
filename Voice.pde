public class Voice {
  long currentSpeakerId;
  int index;
  int curAudioDuration; 
  int curAudioId;
  String curAudioText = "";
  String currentSpeakerName = "";
  boolean isPlaying = false;
  int interval;
  int lastTimeCheck = 0;
  float reverb;
  boolean isActive = false;

  Voice (int _index, boolean _isActive, int _interval, float _reverb) {
    interval = _interval;
    index = _index;
    isActive = _isActive;
    reverb = _reverb;
  }

  void play (JSONObject audio) {
    curAudioDuration = audio.getInt("duration_seconds") * 1000 + 500;
    lastTimeCheck = millis();
    isPlaying = true;
    currentSpeakerId = audio.getLong("from_id");
    curAudioId = audio.getInt("id");
    currentSpeakerName = audio.getString("from");
    curAudioText = audio.getString("text");
    orchestration.sendOscplay(currentSpeakerId, curAudioId, curAudioText, index, reverb);
  }

  void end () {
    orchestration.sendOscEnd(currentSpeakerId, curAudioId);
    reset();
  }

  void reset () {
    curAudioDuration = 0;
    isPlaying = false;
    curAudioId = 0;
    currentSpeakerId = 0;
    currentSpeakerName = "";
    curAudioText = "";
  }

  void setActive(boolean val) {
    isActive = val;
    if (val == false) {
      if (isPlaying) {
        end();
      } else {
        reset();
      }
    }
  }

  void setInterval (int val) {
    interval = val;
  }

  void setReverb (float val) {
    reverb = val; 
  }

  void update () {
    if (isActive) {
      if (!isPlaying) {
        if (millis() > lastTimeCheck + interval ) {
          // here pick on audio 
          JSONObject audio = orchestration.getNextAudio(index);
          play(audio);
        }
      } else {
        // check if audio has finnished playing
        if (millis() > lastTimeCheck + curAudioDuration) {
          end();
        }
      }
    } 
    debug();
  }

  void debug () {
    if (isActive) {
      text(index + ": " + currentSpeakerName + " "  + curAudioText, 420, voicesControlHeight + voiceControlSpacing * index);
    } else {
      pushStyle();
      fill(255, 0, 0);
      text(index + ": inactive", 420, voicesControlHeight + voiceControlSpacing * index);
      popStyle();
    }
  }

  boolean getIsPlaying () {
    return isPlaying;
  }

  long getSpeakerId () {
    return currentSpeakerId;
  }
}
