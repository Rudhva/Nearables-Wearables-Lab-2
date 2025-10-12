void setupMeditationScreen(Screen s, UIManager ui) {
  noStroke();

    Button waiting = new Button(width/2 - 250, height/2 - 40, 500, 80, "Waiting for the baseline HR to be calculated!", 0, primaryColor3);
  s.add(waiting);

  s.add(waiting);
  s.off();
  ui.addScreen(s);
}




// -------------------
// Meditation globals
int badBreathCount = 0;          // counts consecutive bad breaths
boolean inBreath = false;        // are we in an inhalation phase?
int breathStartTime = 0;         // start time of current breath
float lastFSR = 0;
float inhaleDuration = 0;
float exhaleDuration = 0;
float ratioThresholdLow = 0.30;  // 1/3 inhale lower bound
float ratioThresholdHigh = 0.36; // 1/3 inhale upper bound

void runningMeditationScreen(Screen s) {
  noStroke();
  s.components.clear();

  // Get current FSR value
  float fsrNow = myGraph.fsrValues[(myGraph.headFSR - 1 + myGraph.fsrValues.length) % myGraph.fsrValues.length];

  // Detect inhalation/exhalation (simple derivative-based)
  float diff = fsrNow - lastFSR;
  lastFSR = fsrNow;

  int now = millis();

  if (!inBreath && diff > 2) {  // threshold for inhalation start
    inBreath = true;
    breathStartTime = now;
    exhaleDuration = now - breathStartTime;  // previous exhale
  } 
  else if (inBreath && diff < -2) { // inhalation ended -> exhale started
    inBreath = false;
    inhaleDuration = now - breathStartTime;

    // Check 1:3 ratio
    if (inhaleDuration / exhaleDuration < ratioThresholdLow || inhaleDuration / exhaleDuration > ratioThresholdHigh) {
      badBreathCount++;
    } else {
      badBreathCount = 0;
    }

    breathStartTime = now; // start of exhale
  }

  // Display meditation info
  s.add(new Message(width/2, height/2 - 60, "Meditation in progress", 20));
  s.add(new Message(width/2, height/2, 
    "HR: -- bpm\nResp: --", 18)); // placeholder, add real HR/resp calculations if needed

  // Show indicator if 3 consecutive bad breaths
  if (badBreathCount >= 3) {
    s.add(new Message(width/2, height/2 + 60, "Adjust your breathing!", 22));
  }

  ui.addScreen(s);
}
