void setupFitnessScreen(Screen s, UIManager ui) {
  myGraph = new SerialGraph(50, 100, 800, 400, myPort);
  s.add(myGraph);

  Button fitnessBtn = new Button(width/2 - 100, height - 100, 200, 50, "Fitness Action", 0, primaryColor2);
  fitnessBtn.onClick = () -> fitnessBtn.pressed = !fitnessBtn.pressed;
  s.add(fitnessBtn);

  ui.addScreen(s); 
}

// -------------------
// Draw reference lines and HR zones
void GraphVisualElements(SerialGraph g) {
  pushMatrix();
  translate(g.x, g.y);

  // Draw horizontal reference lines every 20 bpm
  stroke(150); // light gray
  strokeWeight(1);
  fill(0);
  textSize(12);
  textAlign(RIGHT, CENTER);

  for (int bpm = 0; bpm <= 220; bpm += 20) {
    float yPos = map(bpm, 0, 220, g.graphHeight, 0);
    line(0, yPos, g.graphWidth, yPos);        // reference line
    text(bpm, -10, yPos);                     // label on left
  }

  // Optional: draw HR zones as background bands
  noStroke();
  fill(0, 255, 0, 30);                        // Resting green (0–100)
  rect(0, map(100, 0, 220, g.graphHeight, 0), g.graphWidth, g.graphHeight - map(100, 0, 220, g.graphHeight, 0));

  fill(255, 165, 0, 30);                      // Moderate orange (100–140)
  rect(0, map(140, 0, 220, g.graphHeight, 0), g.graphWidth, map(100, 0, 220, g.graphHeight, 0) - map(140, 0, 220, g.graphHeight, 0));

  fill(255, 0, 0, 30);                        // High red (140–220)
  rect(0, 0, g.graphWidth, map(140, 0, 220, g.graphHeight, 0));

  popMatrix();
}
