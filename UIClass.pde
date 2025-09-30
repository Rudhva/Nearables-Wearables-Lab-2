abstract class UIComponent {
  float x, y, w, h;
  int layer = 0;
  boolean visible = true;

  UIComponent(float x, float y, float w, float h) {
    this.x = x; this.y = y; this.w = w; this.h = h;
  }

  abstract void display();
  abstract void handleInput();

  boolean isHovered() {
    return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  }
}

class Button extends UIComponent {
  String label;
  boolean pressed = false;

  Button(float x, float y, float w, float h, String label, int layer) {
    super(x, y, w, h);
    this.label = label;
    this.layer = layer;
  }

  void display() {
    if (!visible) return;
    fill(pressed ? color(100, 200, 100) : color(200, 100, 100));
    rect(x, y, w, h, 8);
    fill(255);
    textAlign(CENTER, CENTER);
    text(label, x + w/2, y + h/2);
  }

  void handleInput() {
    if (!visible) return;
    if (isHovered()) pressed = !pressed;
  }
}

class Screen {
  ArrayList<UIComponent> components = new ArrayList<UIComponent>();
  boolean visible = true;

  void add(UIComponent c) {
    components.add(c);
  }

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

class UIManager {
  ArrayList<UIComponent> components = new ArrayList<UIComponent>();
  ArrayList<Screen> screens = new ArrayList<Screen>();

  void add(UIComponent c) {
    components.add(c);
  }

  void addScreen(Screen s) {
    screens.add(s);
  }

  void display() {
    // Screens first
    for (Screen s : screens) s.display();
    // Top-level components
    components.sort((a,b) -> a.layer - b.layer);
    for (UIComponent c : components) if (c.visible) c.display();
  }

  void handleInput() {
    // Screens first
    for (Screen s : screens) s.handleInput();
    // Top-level components
    for (int i = components.size()-1; i>=0; i--) {
      UIComponent c = components.get(i);
      if (c.visible && c.isHovered()) {
        c.handleInput();
        break;
      }
    }
  }
}
