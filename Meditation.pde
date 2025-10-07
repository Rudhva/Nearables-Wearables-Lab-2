void setupMeditationScreen(Screen s, UIManager ui) {
  noStroke();
  Button medBtn1 = new Button(width*0.2, height/2 - 30, 120, 60, "Cream BG", 0, primaryColor2);
  medBtn1.onClick = () -> meditationBg = primaryColor2;
  Button medBtn2 = new Button(width*0.6, height/2 - 30, 120, 60, "Pink BG", 0, primaryColor3);
  medBtn2.onClick = () -> meditationBg = primaryColor3;

  s.add(medBtn1);
  s.add(medBtn2);
  s.off();
  ui.addScreen(s);
}