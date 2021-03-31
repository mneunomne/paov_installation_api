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

float aoff = 0.0;
float roff = 0.0;
NoiseCircluarWalker n;

int numSpeakers = 25;
ArrayList<NoiseCircluarWalker> walkers = new ArrayList<NoiseCircluarWalker>();

float minRadius;
float maxRadius;

Orchestration orchestration1;
Orchestration orchestration2;
Orchestration orchestration3;

void setup() {
  size(400, 400);
  minRadius = 100;
  maxRadius = width/2;
  cp5 = new ControlP5(this);
  range = cp5.addRange("rangeController")
             .setBroadcast(false) 
             .setPosition(0,0)
             .setSize(400,20)
             .setHandleSize(10)
             .setRange(0,width)
             .setRangeValues(minRadius, maxRadius)
             .setBroadcast(true)
             .setColorForeground(color(255,40))
             .setColorBackground(color(255,40))  
             ;
  
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
  orchestration1 = new Orchestration(audios);
  orchestration2 = new Orchestration(audios);
  orchestration3 = new Orchestration(audios);
  JSONArray speakers = json.getJSONArray("speakers");
  for (int i = 0; i < speakers.size(); i++) {    
    JSONObject item = speakers.getJSONObject(i); 
    String name = item.getString("speaker");
    long id = item.getLong("id");
    // println(name, id);
    NoiseCircluarWalker n = new NoiseCircluarWalker(id, name, i);
    walkers.add(n);
  }
}

void draw() {
  background(0);
  noFill();
  stroke(255);
  ellipse(width/2, height/2, height/2,height/2);
  
  // orchestration update
  orchestration1.update();
  orchestration2.update();
  orchestration3.update();
  
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
}
