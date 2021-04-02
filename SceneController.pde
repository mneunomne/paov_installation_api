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

  SceneController () {
  }

  void loadScene (int index) {
    if (isTransitioning) return;
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
    if (isTransitioning) {
      // float values
      for (int i = 0; i < floatValuesNames.size(); i++) {
        float value = tween(floatStartValues.get(i), floatEndValues.get(i), transitionTime);
        cp5.getController(floatValuesNames.get(i)).setValue(value);
      }
      // intvalues
      for (int i = 0; i < intValuesNames.size(); i++) {
        int value = int(tween(intStartValues.get(i), intEndValues.get(i), transitionTime));
        cp5.getController(intValuesNames.get(i)).setValue(value);
      }
      // range
      float values[] = new float[2];
      values[0] = tween(rangeStartValues[0], rangeEndValues[0], transitionTime);
      values[1] = tween(rangeStartValues[1], rangeEndValues[1], transitionTime);
      cp5.getController(rangeName).setArrayValue(values);
     
      if (millis() - initTransitionTime > transitionTime) {
        println("END TRANSITION!");
        reset();
        isTransitioning = false;
      }
    }
  }
  
  void reset () {
    intStartValues.clear();
    intEndValues.clear();
    intValuesNames.clear();
    
    floatStartValues.clear();
    floatEndValues.clear();
    floatValuesNames.clear();
  }

  float tween(float start, float end, int transitionTime) {
    float a = float(millis() - initTransitionTime) / transitionTime;
    float t = a;
    float x = AULib.ease(AULib.EASE_IN_OUT_CUBIC, t);
    return map(x, 0, 1, start, end);
  }
}
