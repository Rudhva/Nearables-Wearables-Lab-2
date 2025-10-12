// -------------------
// Fitness Mode Age Input
// -------------------
int userAge = -1;  // -1 means "not yet set"

// Call this at the start of fitness mode
void askUserAge() {
  if (userAge == -1) {  // only ask once
    String input = javax.swing.JOptionPane.showInputDialog("Please enter your age: (99 will give fake data)");
    if (input != null && input.length() > 0) {
      try {
        userAge = Integer.parseInt(input);
        println("User age set to: " + userAge);
      } catch (NumberFormatException e) {
        println("Invalid input, using default age 0");
        userAge = 0;  // fallback if invalid
      }
    } else {
      userAge = 0;  // fallback if user cancels
    }
  }
}


void setupFitnessScreen(Screen s, UIManager ui) {
  myGraph = new SerialGraph(50, 100, 800, 400);
  s.add(myGraph);
  askUserAge();

  if(userAge == 99){
    Thread fakeReader = new Thread(new FakeSerialReader());
  fakeReader.start();
  } else {
    Thread readerThread = new Thread(new SerialReader());
    readerThread.start();
  }
 
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
    float yPos = map(bpm, 0, 220, g.h, 0);
    line(0, yPos, g.w, yPos);        // reference line
    text(bpm, -10, yPos);                     // label on left
  }

  // Optional: draw HR zones as background bands
  noStroke();
  fill(0, 255, 0, 30);                        // Resting green (0–100)
  rect(0, map(100, 0, 220, g.h, 0), g.w, g.h - map(100, 0, 220, g.h, 0));

  fill(255, 165, 0, 30);                      // Moderate orange (100–140)
  rect(0, map(140, 0, 220, g.h, 0), g.w, map(100, 0, 220, g.h, 0) - map(140, 0, 220, g.h, 0));

  fill(255, 0, 0, 30);                        // High red (140–220)
  rect(0, 0, g.w, map(140, 0, 220, g.h, 0));

  popMatrix();
}
