

// ----------------------------
// Setup Monitoring Screen
// ----------------------------
void setupMonitoringScreen(Screen s, UIManager ui) {
  noStroke();

  Button waiting = new Button(width/2 - 250, height/2 - 40, 500, 80, "Waiting for the baseline HR to be calculated!", 0, primaryColor3);
  s.add(waiting);

  s.off(); // start off hidden
  ui.addScreen(s);
}


// ----------------------------
// Monitoring state change
// ----------------------------
void runningMonitoringTab(Screen s, UIManager ui) {
  s.bgColor = successColor;
  s.components.clear();

  // Button: Calm Mode
  Button calmBtn = new Button(width/2 - 220, height/2 - 40, 200, 80,
    "Calm Mode", 0, primaryColor2);
  calmBtn.onClick = () -> {
    calmScreen.on(); // show Calm screen
    s.off();         // hide Monitoring screen
  };
  s.add(calmBtn);

  // Button: Stress Mode
  Button stressBtn = new Button(width/2 + 20, height/2 - 40, 200, 80,
    "Stress Mode", 0, primaryColor3);
  stressBtn.onClick = () -> {
    stressScreen.on(); // show Stress screen
    s.off();           // hide Monitoring screen
  };
  s.add(stressBtn);
}



// -------------------
// Timer globals
int calmTimer = 30_000;       // 30 seconds
int stressTimer = 30_000;
boolean calmRunning = false;
boolean stressRunning = false;
int calmStartTime;
int stressStartTime;

// -------------------
// Single reusable drawTimer function
void drawTimer(int timer, boolean running, int startTime, float x, float y, float w, float h, color fillColor) {
  if (running) {
    int elapsed = millis() - startTime;
    timer = max(30_000 - elapsed, 0);
    if (timer == 0) running = false;
  }

  float pct = timer / 30_000.0;
  fill(fillColor);
  rect(x, y, w * pct, h);
}

// -------------------
// Setup Calm Screen
void setupCalmScreen(Screen s, UIManager ui) {
  s.bgColor = color(132,169,140);
  s.components.clear();

  // Message
  s.add(new Message(width/2, height/2 - 60, "You are now in Calm Mode!", 24));

  // Start button
  Button startBtn = new Button(width/2 - 110, height/2 + 10, 100, 40, "Start", 0, color(0, 200, 0));
  startBtn.onClick = () -> {
    calmRunning = true;
    calmStartTime = millis();
  };
  s.add(startBtn);

  // Reset button
  Button resetBtn = new Button(width/2 + 10, height/2 + 10, 100, 40, "Reset", 0, color(200, 0, 0));
  resetBtn.onClick = () -> {
    calmRunning = false;
    calmTimer = 30_000;
  };
  s.add(resetBtn);

  // Back button
  Button backBtn = new Button(width/2 - 50, height/2 + 60, 100, 40, "Back", 0, color(100));
  backBtn.onClick = () -> {
    calmRunning = false;
    calmTimer = 30_000;
    s.off();
    monitoringScreen.on();
  };
  s.add(backBtn);

  s.off();
  ui.addScreen(s);
}

// -------------------
// Setup Stress Screen
void setupStressScreen(Screen s, UIManager ui) {
  s.bgColor = color(255,179,138);
  s.components.clear();

  s.add(new Message(width/2, height/2 - 60, "Stress Mode Active!", 24));

  // Start button
  Button startBtn = new Button(width/2 - 110, height/2 + 10, 100, 40, "Start", 0, color(0, 200, 0));
  startBtn.onClick = () -> {
    stressRunning = true;
    stressStartTime = millis();
  };
  s.add(startBtn);

  // Reset button
  Button resetBtn = new Button(width/2 + 10, height/2 + 10, 100, 40, "Reset", 0, color(200, 0, 0));
  resetBtn.onClick = () -> {
    stressRunning = false;
    stressTimer = 30_000;
  };
  s.add(resetBtn);

  // Back button
  Button backBtn = new Button(width/2 - 50, height/2 + 60, 100, 40, "Back", 0, color(100));
  backBtn.onClick = () -> {
    stressRunning = false;
    stressTimer = 30_000;
    s.off();
    monitoringScreen.on();
  };
  s.add(backBtn);

  s.off();
  ui.addScreen(s);
}

void updateActiveTimer() {
  if (calmScreen.visible)
    drawTimer(calmTimer, calmRunning, calmStartTime, width/2 - 150, height/2 - 20, 300, 20, color(255, 200, 0));
  if (stressScreen.visible)
    drawTimer(stressTimer, stressRunning, stressStartTime, width/2 - 150, height/2 - 20, 300, 20, color(255, 0, 0));
}