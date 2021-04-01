public class Orchestration { 
  JSONArray audios;
  Voice[] voices = new Voice[maxNumVoices];
  
  Orchestration (JSONArray _audios) {
    audios = _audios;
    
    // initiate all voices
    for (int i = 0; i < maxNumVoices; i++) {
     voices[i] = new Voice(i, i < numActiveVoices,0); 
    }
  }
  
  void setActiveVoices (int amount) {
    numActiveVoices = amount;
  }
  
  void update () {
    for(int i = 0; i < numActiveVoices; i++) {
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
  
  void sendOscplay (long speakerId, int audioID, String audioText) {
    OscMessage visMessage = new OscMessage("/play");
    visMessage.add(Long.toString(speakerId));
    visMessage.add(audioID);
    visMessage.add(audioText);
    oscP5.send(visMessage, localBroadcast);
    
    OscMessage audioMessage = new OscMessage("/play");
    audioMessage.add(Long.toString(speakerId));
    audioMessage.add(audioID);
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
}
