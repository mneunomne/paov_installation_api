public class Voice {
 long currentSpeakerId;
 int index;
 int curAudioDuration; 
 int curAudioId;
 String curAudioText;
 String currentSpeakerName;
 boolean isPlaying = false;
 int interval;
 int lastTimeCheck = 0;
 
 boolean isActive = false;
 
 Voice (int _index, boolean _isActive, int _interval) {
   interval = _interval;
   index = _index;
   isActive = _isActive;
 }
 
 void play (JSONObject audio) {
    curAudioDuration = audio.getInt("duration_seconds") * 1000 + 500;
    lastTimeCheck = millis();
    isPlaying = true;
    currentSpeakerId = audio.getLong("from_id");
    curAudioId = audio.getInt("id");
    currentSpeakerName = audio.getString("from");
    curAudioText = audio.getString("text");
    orchestration.sendOscplay(currentSpeakerId, curAudioId, curAudioText);
  }
 
 void end () {
    curAudioDuration = 0;
    lastTimeCheck = millis();
    isPlaying = false;
    orchestration.sendOscEnd(currentSpeakerId, curAudioId);
    curAudioId = 0;
    currentSpeakerId = 0;
    currentSpeakerName = "";
  }
  
  void setActive(boolean val) {
    isActive = val; 
  }
  
  void setInterval (int val) {
    interval = val;
  }
 
 void update () {
    if (!isPlaying) {
      if (millis() > lastTimeCheck + interval ) {
        // here pick on audio 
        JSONObject audio = orchestration.getNextAudio();
        play(audio);
      }      
    } else {
      // check if audio has finnished playing
      if (millis() > lastTimeCheck + curAudioDuration) {
        end();
      }
    }
    debug();
  }
  
  void debug () {
    text(index + ": " + currentSpeakerName, 420, 200 + 20 * index); 
  }
  
  long getSpeakerId () {
    return currentSpeakerId; 
  }
}
