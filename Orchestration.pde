class Orchestration { 

  int lastTimeCheck = 0;
  int timeIntervalFlag = 300; // 3 seconds because we are working with millis

  int interval;
  JSONArray audios;

  boolean isPlaying = false;

  int curAudioDuration; 
  int curAudioId;
  int currentSpeakerId;
  String currentSpeakerName;
  String curAudioText;
  Orchestration (JSONArray _audios) {
    audios = _audios;
  }

  void update () {
    if (!isPlaying) {
      if (millis() > lastTimeCheck + timeIntervalFlag ) {
        // here pick on audio 
        JSONObject audio = getNextAudio();
        play(audio);
      }      
    } else {
      // check if audio has finnished playing
      if (millis() > lastTimeCheck + curAudioDuration) {
        end();
      }
      // debug
      fill(255);
      text("curAudio: " + curAudioId, 0, height-20);
      text("curText: " + curAudioText, 0, height-40);
    }
    
  }

  JSONObject getNextAudio () {
    int index = floor(random(0, audios.size()));
    return audios.getJSONObject(index);
  }

  void play (JSONObject audio) {
    curAudioDuration = audio.getInt("duration_seconds") * 1000 + 500;
    lastTimeCheck = millis();
    isPlaying = true;
    currentSpeakerId = audio.getInt("from_id");
    curAudioId = audio.getInt("id");
    currentSpeakerName = audio.getString("from");
    curAudioText = audio.getString("text");
    sendOscplay();
  }

  void end () {
    curAudioDuration = 0;
    lastTimeCheck = millis();
    isPlaying = false;
    sendOscEnd();
    currentSpeakerId = 0;
  }
  
  void sendOscplay () {
    OscMessage visMessage = new OscMessage("/play");
    visMessage.add(currentSpeakerId);
    visMessage.add(curAudioId);
    visMessage.add(curAudioText);
    oscP5.send(visMessage, localBroadcast);
    
    OscMessage audioMessage = new OscMessage("/play");
    audioMessage.add(currentSpeakerId);
    audioMessage.add(curAudioId);
    audioMessage.add(curAudioText);
    oscP5.send(audioMessage, remoteBroadcast);
  }
  
  void sendOscEnd () {
    OscMessage myOscMessage = new OscMessage("/end");
    myOscMessage.add(currentSpeakerId);
    myOscMessage.add(curAudioId);
    oscP5.send(myOscMessage, localBroadcast);
  }
  
  int getCurrentSpeakerId () {
    return currentSpeakerId;
  }
}
