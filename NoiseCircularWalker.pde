// Noise Walker
class NoiseCircluarWalker {
  float aoff;
  float roff;
  float aVel = .001;
  float rVel = .001;
  long id; 
  float posX, posY;
  String name; 
  int index; 
  NoiseCircluarWalker (long _id, String _name, int _index) {
    aoff = random(10000);
    roff = random(10000);
    id = _id;
    name = _name;
    index = _index;
  }
  
  void update() {
    noiseDetail(2,0.5);
    aoff = aoff + aVel;
    roff = roff + rVel;
    float theta = noise(aoff) * 4 * PI;
    float radius = map(noise(roff), 0, 1, minRadius, maxRadius);
    posX = radius * cos( theta );
    posY = radius * sin( theta );
    pushMatrix();
    
    if (
      orchestration1.getCurrentSpeakerId() == id ||
      orchestration2.getCurrentSpeakerId() == id ||
      orchestration3.getCurrentSpeakerId() == id
    ) {
      fill(255); 
    } else {
      noFill();
    }

    
    translate(width/2, height/2);
    ellipse(posX, posY, 4, 4);
    popMatrix();
    sendOSC(theta, radius);
  }
  
  void setAngleVelocity (float vel) {
    aVel = vel / 10000;
  }
  
  void setRadiusVelocity (float vel) {
    rVel = vel / 10000;
  }
  
  void sendOSC (float theta, float radius) {
    OscMessage visMessage = new OscMessage("/pos");
    visMessage.add(index);
    visMessage.add(theta);
    visMessage.add(radius / height);
    oscP5.send(visMessage, localBroadcast);
    
    
    OscMessage audioMessage = new OscMessage("/pos");
    audioMessage.add(Long.toString(id));
    audioMessage.add((theta / (PI * 2) * 360) % 360);
    audioMessage.add(radius / (height/2));
    oscP5.send(audioMessage, remoteBroadcast);
  }
}
