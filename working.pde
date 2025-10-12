// -------------------
// Global color palette
color primaryColor1     = color(111, 78, 97);    // Deep Plum
color primaryColor2     = color(244, 235, 211);  // Light Beige
color primaryColor3     = color(232, 188, 185);  // Pinkish
color backgroundColor   = color(152, 161, 188);  // Light Blueish
color successColor      = color(116, 194, 155);  // Greenish
color meditationBg;

//UI Variables
UIManager ui;
Screen fitnessScreen, monitoringScreen, meditationScreen, extraScreen, stressScreen, calmScreen;
Button fitnessTabBtn, monitoringTabBtn, meditationTabBtn, extraTabBtn; 
Screen[] screens;
Button[] tabs;
// -------------------


//Serial Stuff

// -------------------

void setup() {
  size(1000, 750);
  frameRate(30);

  textAlign(CENTER, CENTER);
  textSize(14);

  ui = new UIManager();
  meditationBg = backgroundColor;

  // Screens
  setupSerial();
  fitnessScreen = new Screen();  
  setupFitnessScreen(fitnessScreen, ui);

  //
  monitoringScreen = new Screen();
  setupMonitoringScreen(monitoringScreen, ui);
      calmScreen = new Screen();
      setupCalmScreen(calmScreen, ui);

      stressScreen = new Screen();
      setupStressScreen(stressScreen, ui);
  //

  meditationScreen = new Screen();
  setupMeditationScreen(meditationScreen, ui);

  extraScreen = new Screen();
  setupExtraScreen(extraScreen, ui);

  // Tabs
  setupTabs();
  
}


void draw() {
  drawBackground();
  ui.display();
  updateActiveTimer();

  if (calmScreen.visible && calmRunning) drawCalmBubbles(); // show bubbles only when Calm screen is running
  if (stressScreen.visible && stressRunning) drawStressQuiz();

  // THIS IS THE BASELINE 
  if(millis() > 2000) {runningMonitoringTab(monitoringScreen); runningMeditationScreen(meditationScreen);} 
}

void mousePressed() {
  ui.handleInput();
  if (stressScreen.visible && stressRunning) mousePressedStressQuiz();
}

void mouseReleased() {
  if (stressScreen.visible && stressRunning) mouseReleasedStressQuiz();
}


// -------------------
// Tabs setup
void setupTabs() {
  noStroke();
  float tabW = width / 4.0;
  float tabH = height * 0.06;
  fitnessTabBtn      = new Button(0, 0, tabW, tabH, "Fitness", 10, primaryColor1);
  monitoringTabBtn   = new Button(tabW, 0, tabW, tabH, "Stress Mode", 10, primaryColor1);
  meditationTabBtn   = new Button(tabW * 2, 0, tabW, tabH, "Meditation", 10, primaryColor1);
  extraTabBtn        = new Button(tabW * 3, 0, tabW, tabH, "Extra", 10, primaryColor1);

  // --- Make tab fonts white and bold ---
  fitnessTabBtn.textColor = color(255);
  monitoringTabBtn.textColor = color(255);
  meditationTabBtn.textColor = color(255);
  extraTabBtn.textColor = color(255);
  // -------------------------------------

  tabs = new Button[]{fitnessTabBtn, monitoringTabBtn, meditationTabBtn, extraTabBtn};
  screens = new Screen[]{fitnessScreen, monitoringScreen, meditationScreen, extraScreen};

  for (int i = 0; i < tabs.length; i++) {
    int idx = i;
    tabs[i].onClick = () -> {
      for (int j = 0; j < screens.length; j++) screens[j].visible = (j == idx);
    };
    ui.add(tabs[i]);
  }
}

// -------------------
// Background drawing
void drawBackground() {
  if (meditationScreen.visible) {
    background(meditationBg);
  } else {
    background(backgroundColor);
  }
}
