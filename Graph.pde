import processing.serial.*;
SerialGraph myGraph;
Serial myPort;          
float[] values;

void setupSerial() {
  if (Serial.list().length > 0) {
    String portName = Serial.list()[Serial.list().length - 1];
    myPort = new Serial(this, portName, 9600);
  }

  // Start serial reading in background thread
  Thread readerThread = new Thread(new SerialReader());
  readerThread.start();
}



// ------------------------ SERIAL READER THREAD ------------------------
class SerialReader implements Runnable {
  public void run() {
    while (true) {
      if (myPort != null && myPort.available() > 0) {
        String inString = trim(myPort.readStringUntil('\n'));
        if (inString != null && inString.length() > 0) {
          try {
            float val = float(inString);
            myGraph.addValue(val);       // store raw HR (0-220)
            println("Current Reading Value: ", val);
          } catch(Exception e) {
            println("Invalid data: " + inString);
          }
        }
      }
      try { Thread.sleep(2); } catch(Exception e) {}
    }
  }
}



// ------------------------ SERIAL GRAPH ------------------------
class SerialGraph extends UIComponent {
  Serial myPort;
  float[] values;       // store raw HR values (0-220)
  int graphWidth, graphHeight;
  int head = 0;         // circular buffer

  SerialGraph(float x, float y, float w, float h, Serial myPort) {
    super(x, y, w, h);
    this.graphWidth = int(w);
    this.graphHeight = int(h);
    values = new float[graphWidth];   // raw HR values
    this.myPort = myPort;
  }

  // Add new HR value (0-220)
  void addValue(float hr) {
    hr = constrain(hr, 0, 220);       // clamp
    synchronized(values) {
      values[head] = hr;
      head = (head + 1) % values.length;
    }
  }

  void display() {
    if (!visible) return;
    pushMatrix();
    translate(x, y);  // move to top-left of graph

    // Draw HR zones and reference lines
    GraphVisualElements(this);

    // Draw HR line
    strokeWeight(2);
    for (int i = 0; i < values.length-1; i++) {
      int idx1 = (head + i) % values.length;
      int idx2 = (head + i + 1) % values.length;

      float y1 = map(values[idx1], 0, 220, graphHeight, 0);
      float y2 = map(values[idx2], 0, 220, graphHeight, 0);

      // Color based on HR zone
      if (values[idx2] < 100) stroke(0, 255, 0);
      else if (values[idx2] < 140) stroke(255, 165, 0);
      else stroke(255, 0, 0);

      line(i, y1, i+1, y2);
    }

    popMatrix();
  }

  void handleInput() {}

  boolean isHovered() { return false; }
}
