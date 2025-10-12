

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
void runningMonitoringTab(Screen s) {
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
    startCalmBubbles(); // activate bubbles
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

  s.add(new Message(width/2, 100, "Stress Mode Active!", 24));

  // Start button
  Button startBtn = new Button(width/2 - 110, height/5 + 10, 100, 40, "Start", 0, color(255, 100, 0));
  startBtn.onClick = () -> {
    stressRunning = true;
    stressStartTime = millis();
    setupStressQuiz(); // initialize quiz handles and questions
  };
  s.add(startBtn);

  // Reset button
  Button resetBtn = new Button(width/2 + 10, height/5 + 10, 100, 40, "Reset", 0, color(200, 0, 0));
  resetBtn.onClick = () -> {
    stressRunning = false;
    stressTimer = 30_000;
  };
  s.add(resetBtn);

  // Back button
  Button backBtn = new Button(width/2 - 50, height/5 + 60, 100, 40, "Back", 0, color(100));
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
    drawTimer(stressTimer, stressRunning, stressStartTime, width/2 - 150, height/5 - 20, 300, 20, color(255, 0, 0));
}



















// -------------------
// Bouncy Bubbles for Calm Screen (found on an example sketch - copy pasted...)
// -------------------
int numBalls = 20;
float spring = 0.05;
float gravity = 0.03;
float friction = -0.9;
Ball[] balls = new Ball[numBalls];
boolean bubblesActive = false;
Thread bubbleThread;

void startCalmBubbles() {
  for (int i = 0; i < numBalls; i++) {
    balls[i] = new Ball(random(width), random(height), random(30, 70), i, balls);
  }
  bubblesActive = true;

  // Start physics thread
  bubbleThread = new Thread(new Runnable() {
    public void run() {
      while (bubblesActive) {
        synchronized (balls) {
          for (Ball b : balls) {
            b.collide();
            b.move();
          }
        }
        try { Thread.sleep(16); } catch (Exception e) {} // ~60 Hz update
      }
    }
  });
  bubbleThread.start();
}

void drawCalmBubbles() {
  if (!bubblesActive) return;

  synchronized (balls) {  // lock while reading positions
    for (Ball ball : balls) {
      fill(255, 204);
      ellipse(ball.x, ball.y, ball.diameter, ball.diameter);
    }
  }
}

class Ball {
  float x, y, diameter, vx = 0, vy = 0;
  int id;
  Ball[] others;

  Ball(float xin, float yin, float din, int idin, Ball[] oin) {
    x = xin; y = yin; diameter = din; id = idin; others = oin;
  }

  void collide() {
    for (int i = id + 1; i < numBalls; i++) {
      float dx = others[i].x - x;
      float dy = others[i].y - y;
      float distance = sqrt(dx*dx + dy*dy);
      float minDist = others[i].diameter/2 + diameter/2;
      if (distance < minDist) {
        float angle = atan2(dy, dx);
        float targetX = x + cos(angle) * minDist;
        float targetY = y + sin(angle) * minDist;
        float ax = (targetX - others[i].x) * spring;
        float ay = (targetY - others[i].y) * spring;
        vx -= ax; vy -= ay;
        others[i].vx += ax; others[i].vy += ay;
      }
    }
  }

  void move() {
    vy += gravity;
    x += vx; y += vy;
    if (x + diameter/2 > width) { x = width - diameter/2; vx *= friction; }
    else if (x - diameter/2 < 0) { x = diameter/2; vx *= friction; }
    if (y + diameter/2 > height) { y = height - diameter/2; vy *= friction; }
    else if (y - diameter/2 < 0) { y = diameter/2; vy *= friction; }
  }
}

// -------------------
// Stop bubbles if Calm ends
void stopCalmBubbles() {
  bubblesActive = false;
  try { bubbleThread.join(); } catch (Exception e) {}
}
























// -------------------
// Quiz-specific Handle
class QuizHandle {
  float x, y;
  float stretch;
  float hsize;
  boolean dragging = false;

  QuizHandle(float xin, float yin, float sin, float hsin) {
    x = xin;
    y = yin;
    stretch = sin;
    hsize = hsin;
  }

  void update() {
    if (dragging) {
      stretch = constrain(mouseX - x, 0, width/2 - 10);
    }
  }

  void display() {
    stroke(0);
    fill(200);
    rect(x, y - hsize, stretch, hsize * 2);
    fill(100);
    ellipse(x + stretch, y, hsize * 2, hsize * 2);
    noStroke();
  }

  void pressEvent() {
    if (dist(mouseX, mouseY, x + stretch, y) < hsize) {
      dragging = true;
    }
  }

  void releaseEvent() {
    dragging = false;
  }
}

// -------------------
// MathQuestion class
class MathQuestion {
  String question;
  int answer;
  QuizHandle handle;

  MathQuestion(String q, int a, QuizHandle h) {
    question = q;
    answer = a;
    handle = h;
  }

  boolean checkAnswer() {
    float val = map(handle.stretch, 0, width/2 - 10, 0, 100);
    return int(val) == answer;
  }
}

// -------------------
// Call in global mousePressed()
void mousePressedStressQuiz() {
  for (QuizHandle h : quizHandles) {
    h.pressEvent();
  }
}

// -------------------
// Call in global mouseReleased()
void mouseReleasedStressQuiz() {
  for (QuizHandle h : quizHandles) {
    h.releaseEvent();
  }

  // Check answers
  quizScore = 0;
  for (MathQuestion q : quiz) {
    if (q.checkAnswer()) quizScore++;
  }
  quizChecked = true;
}


// -------------------
// Quiz globals
int numQuizQuestions = 5; // 5 questions
QuizHandle[] quizHandles;
MathQuestion[] quiz;
boolean firstMousePressQuiz = false;
int quizScore = 0;
boolean quizChecked = false;

// -------------------
// Setup quiz
void setupStressQuiz() {
  int hsize = 10;
  quizHandles = new QuizHandle[numQuizQuestions];
  quiz = new MathQuestion[numQuizQuestions];

  float handleStartX = width/4;       // left edge of handle
  float startY = height/3 + 80;       // moved further down below timer
  float spacing = 60;                  // vertical spacing between questions

  for (int i = 0; i < numQuizQuestions; i++) {
    quizHandles[i] = new QuizHandle(handleStartX, startY + i*spacing, 0, hsize);
  }

  // Example questions
  quiz[0] = new MathQuestion("5 + 3 * 2 =", 11, quizHandles[0]);
  quiz[1] = new MathQuestion("(8 - 3) * 4 =", 20, quizHandles[1]);
  quiz[2] = new MathQuestion("10 / 2 + 7 =", 12, quizHandles[2]);
  quiz[3] = new MathQuestion("6 * 3 - 4 =", 14, quizHandles[3]);
  quiz[4] = new MathQuestion("15 / 3 + 2 =", 7, quizHandles[4]);
}

// -------------------
// Draw quiz
void drawStressQuiz() {
  float startY = height/3 + 80;  // match setup, slightly above middle
  float spacing = 60;
  float handleMaxStretch = width/2;  // horizontal space for handle

  for (int i = 0; i < numQuizQuestions; i++) {
    quizHandles[i].y = startY + i*spacing;
    quizHandles[i].update();
    quizHandles[i].display();

    fill(0);
    textSize(16);
    textAlign(RIGHT, CENTER); // question left of handle
    text(quiz[i].question, quizHandles[i].x - 20, quizHandles[i].y);

    float val = map(quizHandles[i].stretch, 0, handleMaxStretch, 0, 100);
    textAlign(LEFT, CENTER); // answer right of handle
    text("Answer: " + int(val), quizHandles[i].x + handleMaxStretch + 20, quizHandles[i].y);
  }

  if (quizChecked) {
    fill(0, 150, 0);
    textSize(24);
    textAlign(CENTER, CENTER);
    text("Score: " + quizScore + "/" + numQuizQuestions, width/2, height - 50);
  }
}
