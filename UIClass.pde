// -------------------
// Base UI Component
abstract class UIComponent {
  float x, y, w, h;
  int layer = 0;
  boolean visible = true;

  // --- Font/Text properties ---
  PFont font;
  int txtSize = 16;
  color textColor = color(30); // default dark text
  // ----------------------------

  UIComponent(float x, float y, float w, float h) {
    this.x = x; 
    this.y = y; 
    this.w = w; 
    this.h = h;
    this.font = createFont("Arial", txtSize); // default font
  }

  abstract void display();
  abstract void handleInput();

  boolean isHovered() {
    return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  }
}

// -------------------
// Button
class Button extends UIComponent {
  String label;
  boolean pressed = false;
  Runnable onClick;
  color btnColor;

  Button(float x, float y, float w, float h, String label, int layer, color btnColor) {
    super(x, y, w, h);
    this.label = label;
    this.layer = layer;
    this.btnColor = btnColor;
  }

  void display() {
    if (!visible) return;

    // background
    if (pressed) fill(successColor);
    else fill(btnColor);
    rect(x, y, w, h, 8);

    // label
    fill(textColor);
    textAlign(CENTER, CENTER);
    textFont(font);
    textSize(txtSize);
    text(label, x + w/2, y + h/2);
  }

  void handleInput() {
    if (!visible) return;
    if (isHovered() && onClick != null) onClick.run();
  }
}

// -------------------
// Message
class Message extends UIComponent {
  String msg;

  Message(float x, float y, String msg, int txtSize) {
    super(x, y, 0, 0);
    this.msg = msg;
    this.txtSize = txtSize;
  }

  void display() {
    if (!visible) return;
    fill(textColor);
    textAlign(CENTER, CENTER);
    textFont(font);
    textSize(txtSize);
    text(msg, x, y);
  }

  void handleInput() {}
}

// -------------------
// Screen
class Screen {
  ArrayList<UIComponent> components = new ArrayList<UIComponent>();
  boolean visible = true;

  void add(UIComponent c) { components.add(c); }

  void display() {
    if (!visible) return;
    for (UIComponent c : components) c.display();
  }

  void handleInput() {
    if (!visible) return;
    for (UIComponent c : components) {
      if (c.visible && c.isHovered()) {
        c.handleInput();
        break;
      }
    }
  }

  void on() { visible = true; }
  void off() { visible = false; }
}

// -------------------
// UI Manager
class UIManager {
  ArrayList<UIComponent> components = new ArrayList<UIComponent>();
  ArrayList<Screen> screens = new ArrayList<Screen>();

  void add(UIComponent c) { components.add(c); }
  void addScreen(Screen s) { screens.add(s); }

  void display() {
    for (Screen s : screens) s.display();
    components.sort((a,b) -> a.layer - b.layer);
    for (UIComponent c : components) if (c.visible) c.display();
  }

  void handleInput() {
    for (Screen s : screens) s.handleInput();
    for (int i = components.size()-1; i>=0; i--) {
      UIComponent c = components.get(i);
      if (c.visible && c.isHovered()) {
        c.handleInput();
        break;
      }
    }
  }
}
