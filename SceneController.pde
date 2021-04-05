class SceneController {
  int transitionTime = 5000;
  int initTransitionTime;
  boolean isTransitioning = false;


  ArrayList<Integer> intStartValues = new ArrayList<Integer>();
  ArrayList<Float> floatStartValues = new ArrayList<Float>();

  ArrayList<Integer> intEndValues = new ArrayList<Integer>();
  ArrayList<Float> floatEndValues = new ArrayList<Float>();

  ArrayList<String> intValuesNames = new ArrayList<String>();
  ArrayList<String> floatValuesNames = new ArrayList<String>();

  float rangeStartValues[] = new float[2]; 
  float rangeEndValues[] = new float[2]; 
  String rangeName; 
  
  int currentScene = 0;

  SceneController () {
  }

  void loadScene (int index) {
    if (isTransitioning) return;
    currentScene = index;
    json = loadJSONObject("scene-" + index + ".json");
    for (ControllerInterface t : cp5.getAll()) {
      String obj_key = t.getName();
      JSONObject parameter = json.getJSONObject("/" + obj_key);
      if (obj_key.contains("scene_")) continue;
      // println(obj_key, parameter);
      if (parameter.get("value") == null) {
        rangeEndValues[0] = parameter.getFloat("lowValue");
        rangeEndValues[1] = parameter.getFloat("highValue");
        rangeStartValues = cp5.getController(obj_key).getArrayValue();
        println(rangeStartValues, rangeEndValues); 
        rangeName = obj_key;
      } else {
        // only reverbs need float values...
        if (obj_key.contains("reverb")) {
          float endVal = parameter.getFloat("value");
          float startVal = cp5.getController(obj_key).getValue();
          floatStartValues.add(startVal);
          floatEndValues.add(endVal);
          floatValuesNames.add(obj_key);
        } else {
          int endVal = parameter.getInt("value");
          int startVal = int(cp5.getController(obj_key).getValue());
          intStartValues.add(startVal);
          intEndValues.add(endVal);
          intValuesNames.add(obj_key);
        }
      }
    }
    initTransitionTime = millis();
    isTransitioning = true;
  }

  void update() {
    pushStyle();
    if (isTransitioning) {
      noStroke();
      fill(0, 100);
      rect(width-160, cp5_h - 20, 100, 200);
      fill(255, 0, 0);
      text("transitioning!", width-160, cp5_h+20);
      // float values
      for (int i = 0; i < floatValuesNames.size(); i++) {
        float value = tween(floatStartValues.get(i), floatEndValues.get(i), transitionTime, true);
        cp5.getController(floatValuesNames.get(i)).setValue(value);
      }
      // intvalues
      for (int i = 0; i < intValuesNames.size(); i++) {
        int value = int(tween(intStartValues.get(i), intEndValues.get(i), transitionTime, false));
        cp5.getController(intValuesNames.get(i)).setValue(value);
      }
      // range
      float values[] = new float[2];
      values[0] = tween(rangeStartValues[0], rangeEndValues[0], transitionTime, true);
      values[1] = tween(rangeStartValues[1], rangeEndValues[1], transitionTime, true);
      cp5.getController(rangeName).setArrayValue(values);
     
      if (millis() - initTransitionTime > transitionTime) {
        println("END TRANSITION!");
        reset();
        isTransitioning = false;
      }
    }
    fill(255);
    stroke(255);
    text("current scene: " + (currentScene - 1), width-160, cp5_h);
    popStyle();
  }
  
  void reset () {
    intStartValues.clear();
    intEndValues.clear();
    intValuesNames.clear();
    
    floatStartValues.clear();
    floatEndValues.clear();
    floatValuesNames.clear();
  }
  
  void setTransitionTime (int val) {
    transitionTime = val;
  }

  float tween(float start, float end, int transitionTime, boolean isFloat) {
    float a = float(millis() - initTransitionTime) / transitionTime;
    float t = a;
    float val;
    if (false) {
      val = AULib.ease(AULib.EASE_IN_OUT_CUBIC, t);
    } else {
      val = AULib.ease(AULib.EASE_LINEAR, t);
    }
    return map(val, 0, 1, start, end);
  }
}
