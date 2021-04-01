import netP5.*;
import oscP5.*;

import java.net.URLDecoder;
import java.net.URLEncoder;
import java.io.UnsupportedEncodingException;

OscP5 oscP5;
NetAddress remoteBroadcast; 

NetAddress localBroadcast; 

import controlP5.*;
ControlP5 cp5;
Range range;

float realRadius = 3;

int maxNumVoices = 5;
int numActiveVoices = 1;

float aoff = 0.0;
float roff = 0.0;
NoiseCircluarWalker n;

int initialInterval = 3000;

int numSpeakers = 25;
ArrayList<NoiseCircluarWalker> walkers = new ArrayList<NoiseCircluarWalker>();

float minRadius;
float maxRadius;

Orchestration orchestration;

float blurAmount = 65;

int voicesControlHeight = 200;
int cp5_h = 20;

ArrayList<String> availableVoices = new ArrayList<String>();

void setup() {
  size(800, 400);
  minRadius = 100;
  maxRadius = height/2;
  cp5 = new ControlP5(this);
  int cp5_y = 0;
  // radius range
  cp5.addRange("rangeController")
     .setPosition(420,cp5_h + cp5_y)
     .setSize(200,15)
     .setHandleSize(10)
     .setRange(0,height)
     .setRangeValues(minRadius, maxRadius)
     .setBroadcast(true)
     .setColorForeground(color(255,40))
     .setColorBackground(color(255,40))  
     ;
  cp5_y+=25;
  // angle velocity slider
  cp5.addSlider("angleVelocitySlider")
     .setPosition(420,cp5_h + cp5_y)
     .setSize(200,15)
     .setColorForeground(color(255,40))
     .setColorBackground(color(255,40))
     .setValue(10)
     .setRange(1, 500)
     .setBroadcast(true)
     ;
  cp5_y+=25;
  // radius velocity slider
  cp5.addSlider("radiusVelocitySlider")
     .setPosition(420,cp5_h + cp5_y)
     .setSize(200,15)
     .setColorForeground(color(255,40))
     .setColorBackground(color(255,40))  
     .setValue(10)  
     .setRange(1, 500)
     .setBroadcast(true)
     ;
  cp5_y+=25;
  // number of simoutanous speakers
  cp5.addSlider("numSpeakers")
     .setPosition(420,cp5_h + cp5_y)
     .setSize(200,15)
     .setColorForeground(color(255,40))
     .setColorBackground(color(255,40))  
     .setNumberOfTickMarks(maxNumVoices)
     .setRange(0, maxNumVoices)
     .setValue(numActiveVoices)
     .setBroadcast(true)
     ;
  cp5_y+=25;
  // reverb amount
  cp5.addSlider("reverbAmount")
     .setPosition(420,cp5_h + cp5_y)
     .setSize(200,15)
     .setColorForeground(color(255,40))
     .setColorBackground(color(255,40))  
     .setRange(0, 1)
     .setValue(0.5)
     .setBroadcast(true)
     ;
  
  // individual interval for each voice
  for (int i = 0; i < maxNumVoices; i++) {
    cp5.addSlider("Voice_" + i)
     .setPosition(420,(voicesControlHeight + 5) + 35 * i)
     .setSize(200,15)
     .setColorForeground(color(255,40))
     .setColorBackground(color(255,40))
     .setRange(0, 10000)
     .setValue(initialInterval)
     .setBroadcast(true)
     ;
  }
  
  // noiseSeed(1);
  stroke(255);
  
  connectOSC();
  
  loadJSON();
  ellipseMode(RADIUS);
  smooth();
}

void connectOSC () {
  oscP5 = new OscP5(this,12000);
  localBroadcast = new NetAddress("127.0.0.1",32000);
  remoteBroadcast = new NetAddress("192.168.0.133",32000);
}

JSONObject json;
void loadJSON() {
  json = loadJSONObject("data.json");
  JSONArray audios = json.getJSONArray("audios");
  orchestration = new Orchestration(audios);
  JSONArray speakers = json.getJSONArray("speakers");
  for (int i = 0; i < speakers.size(); i++) {    
    JSONObject item = speakers.getJSONObject(i); 
    String name = item.getString("speaker");
    long id = item.getLong("id");
    NoiseCircluarWalker n = new NoiseCircluarWalker(id, name, i);
    walkers.add(n);
  }
}

void draw() {
  background(0);
  noFill();
  stroke(255);
  ellipse(height/2, height/2, height/2,height/2);
  
  // orchestration update
  orchestration.update();
  
  for(int i = 0; i < numSpeakers; i++) {
    walkers.get(i).update();
  }
  fill(255);
  text("fps: " + frameRate, 0, height - 5);
}


void controlEvent(ControlEvent theControlEvent) {
  if(theControlEvent.isFrom("rangeController")) {
    minRadius = int(theControlEvent.getController().getArrayValue(0));
    maxRadius = int(theControlEvent.getController().getArrayValue(1));
  }
  
  if(theControlEvent.isFrom("rangeController")) {
    minRadius = int(theControlEvent.getController().getArrayValue(0));
  }
  
  if(theControlEvent.isFrom("rangeController")) {
    minRadius = int(theControlEvent.getController().getArrayValue(0));
  }
  
  for (int i = 0; i < maxNumVoices; i++) {
    if(theControlEvent.isFrom("Voice_" + i)) {
       orchestration.setVoiceInterval(i, int(theControlEvent.getController().getValue()));
    }
  }
}


void angleVelocitySlider(float vel) {
  for(int i = 0; i < walkers.size(); i++) {
    walkers.get(i).setAngleVelocity(vel);
  }
}

void radiusVelocitySlider(float vel) {
  for(int i = 0; i < walkers.size(); i++) {
    walkers.get(i).setRadiusVelocity(vel);
  }
}

void numSpeakers (int val) {
  orchestration.setActiveVoices(val);
}

void reverbAmount (float val) {
  OscMessage audioMessage = new OscMessage("/reverb");
  audioMessage.add(val);
  oscP5.send(audioMessage, remoteBroadcast);
}
