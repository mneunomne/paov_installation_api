public class Orchestration { 
  JSONArray audios;
  Voice[] voices = new Voice[maxNumVoices];
  
  Orchestration (JSONArray _audios) {
    audios = _audios;
    
    // initiate all voices
    for (int i = 0; i < maxNumVoices; i++) {
     // get reverb valuefrom cp5
     float voiceReverb = cp5.getController("reverb_" + i).getValue();
     voices[i] = new Voice(i, i < numActiveVoices, initialInterval, voiceReverb); 
    }
  }
  
  void setActiveVoices (int amount) {
    numActiveVoices = amount;
    for(int i = 0; i < maxNumVoices; i++) {
      if (i < numActiveVoices) {
        voices[i].setActive(true); 
      } else {
        voices[i].setActive(false);
      }
    }
  }
  
  void update () {
    for(int i = 0; i < maxNumVoices; i++) {
       voices[i].update();
    }
  }

  JSONObject getNextAudio () {
    ArrayList<JSONObject> filtered = new ArrayList<JSONObject>();
    for (int i = 0; i < audios.size(); i++) {
      JSONObject obj = audios.getJSONObject(i);
      long cur_id = obj.getLong("from_id");
      boolean hasFound = false; 
      for (long id : getCurrentSpeakerId()) {
         if (cur_id == id) {
            hasFound = true;
         }
      }
      if (!hasFound) {
         filtered.add(obj);
      }
    }
    int index = floor(random(0, filtered.size())); 
    return filtered.get(index);
  }
  
  void sendOscplay (long speakerId, int audioID, String audioText, int index, float reverb) {
    // VISUAL
    OscMessage visMessage = new OscMessage("/play");
    visMessage.add(Long.toString(speakerId));
    visMessage.add(audioID);
    visMessage.add(audioText);
    oscP5.send(visMessage, localBroadcast);
    
    // set the index of MaxMSP "voice player" a way to save memory in MaxMSP
    for (NoiseCircluarWalker walker : walkers) {
      long _id = walker.getSpeakerId();
      if (_id == speakerId) {
         walker.setVoiceIndex(index);
      }
    }
    
    println("PLAY! " + audioText);
        
    // AUDIO
    OscMessage audioMessage = new OscMessage("/play");
    audioMessage.add(Long.toString(speakerId));
    audioMessage.add(audioID);
    audioMessage.add(index);
    audioMessage.add(reverb);
    oscP5.send(audioMessage, remoteBroadcast);
  }
  
  void sendOscEnd (long speakerId, int audioID) {
    OscMessage myOscMessage = new OscMessage("/end");
    myOscMessage.add(Long.toString(speakerId));
    myOscMessage.add(audioID);
    oscP5.send(myOscMessage, localBroadcast);
  }
  
  long [] getCurrentSpeakerId () {
    long [] ids = new long[numActiveVoices];
    for(int i = 0; i < numActiveVoices; i++) {
       ids[i] = voices[i].getSpeakerId();
    }
    return ids;
  }
  
  void setVoiceInterval (int index, int value) {
    voices[index].setInterval(value);
  }
  
  void setVoiceReverb (int index, float value) {
    voices[index].setReverb(value);
  }
}
