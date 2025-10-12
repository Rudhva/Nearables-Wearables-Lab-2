void setupExtraScreen(Screen s, UIManager ui) {
  noStroke();
  Button info = new Button(250, 250, 300, 300, "Under Construction!", 1, primaryColor3);
  s.add(info);
  s.off();
  ui.addScreen(s);
}
