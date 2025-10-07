void setupStressScreen(Screen s, UIManager ui) {
  noStroke();
  Button stressBtn = new Button(width/2 - 100, height/2 - 40, 200, 80, "Stress Button", 0, primaryColor2);
  stressBtn.onClick = () -> stressBtn.pressed = !stressBtn.pressed;
  s.add(stressBtn);
  s.off();
  ui.addScreen(s);
}