UIManager ui;
Screen tab1Screen, tab2Screen, tab3Screen;
Button tab1Btn, tab2Btn, tab3Btn;

void setup() {
  size(600, 400);
  ui = new UIManager();

  // Screens
  tab1Screen = new Screen();
  tab2Screen = new Screen();
  tab3Screen = new Screen();
  
  // Example content for each screen
  tab1Screen.add(new Button(100, 100, 150, 60, "Tab1 Btn1", 0));
  tab2Screen.add(new Button(100, 100, 150, 60, "Tab2 Btn1", 0));
  tab3Screen.add(new Button(100, 100, 150, 60, "Tab3 Btn1", 0));

  // Default: show tab1
  tab1Screen.on();
  tab2Screen.off();
  tab3Screen.off();
  
  // Add screens to UIManager
  ui.addScreen(tab1Screen);
  ui.addScreen(tab2Screen);
  ui.addScreen(tab3Screen);

  // Tab buttons (always on top layer)
  tab1Btn = new Button(50, 20, 100, 30, "Tab 1", 10);
  tab2Btn = new Button(160, 20, 100, 30, "Tab 2", 10);
  tab3Btn = new Button(270, 20, 100, 30, "Tab 3", 10);

  ui.add(tab1Btn);
  ui.add(tab2Btn);
  ui.add(tab3Btn);
}

void draw() {
  background(240);
  ui.display();
}

void mousePressed() {
  ui.handleInput();

  // Tab button logic
  if (tab1Btn.isHovered()) {
    tab1Screen.on();
    tab2Screen.off();
    tab3Screen.off();
  } else if (tab2Btn.isHovered()) {
    tab1Screen.off();
    tab2Screen.on();
    tab3Screen.off();
  } else if (tab3Btn.isHovered()) {
    tab1Screen.off();
    tab2Screen.off();
    tab3Screen.on();
  }
}
