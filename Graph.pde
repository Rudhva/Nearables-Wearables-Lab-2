import processing.serial.*;

Serial myPort;
SerialGraph myGraph;


// -------------------- SERIAL SETUP --------------------
void setupSerial() {
  if (Serial.list().length > 0) {
    String portName = Serial.list()[Serial.list().length - 1];
    myPort = new Serial(this, portName, 115200);
  }  
}

// -------------------- FAKE DATA GENERATOR --------------------
class FakeSerialReader implements Runnable {
  public void run() {
    float t = 0;
    float fsrBase = 500;      // baseline
    float fsrAmplitude = 200; // peak amplitude
    float breathCycle = 2.0;  // total seconds per breath (inhale + exhale)

    while (true) {
      // -----------------
      // ECG: stylized P-QRS-T waveform
      // -----------------
      float phase = (t % 1.0); // 1-second heartbeat cycle
      float ecgRaw = 0;

      ecgRaw += 0.1 * exp(-pow((phase - 0.1) / 0.02, 2));  // P wave
      ecgRaw += -0.15 * exp(-pow((phase - 0.2) / 0.01, 2)); // Q wave
      ecgRaw += 1.0 * exp(-pow((phase - 0.25) / 0.015, 2)); // R wave
      ecgRaw += -0.25 * exp(-pow((phase - 0.28) / 0.01, 2));// S wave
      ecgRaw += 0.3 * exp(-pow((phase - 0.4) / 0.04, 2));   // T wave
      ecgRaw += random(-0.02, 0.02); // small noise
      float ecg = constrain(ecgRaw, -1, 1) * 512;

      // -----------------
      // Realistic FSR breathing (~1 sec inhale, 1 sec exhale)
      // -----------------
      float breathPhase = (t % breathCycle) / breathCycle; // normalized [0,1]
      float fsr;

      if (breathPhase < 0.25) {
        // inhale ramp (first 25% of cycle)
        fsr = map(breathPhase, 0, 0.25, 0, fsrAmplitude);
      } else if (breathPhase < 0.5) {
        // hold at peak
        fsr = fsrAmplitude;
      } else if (breathPhase < 0.75) {
        // exhale ramp
        fsr = map(breathPhase, 0.5, 0.75, fsrAmplitude, 0);
      } else {
        // hold at baseline
        fsr = 0;
      }

      fsr += fsrBase;          // add baseline offset
      fsr += random(-5, 5);    // small noise

      // -----------------
      // Feed to graph
      // -----------------
      myGraph.addECG(ecg);
      myGraph.addFSR(fsr);

      t += 0.004;
      delay(4);
    }
  }
}


// -------------------------------------------------------------




// -------------------- SERIAL READER --------------------
class SerialReader implements Runnable {
  public void run() {
while (true) {
  if (myPort != null && myPort.available() > 0) {
    String inString = trim(myPort.readStringUntil('\n'));
    if (inString == null || inString.length() < 2) continue; // ignore invalid lines

    try {
      if (inString.startsWith("ECG:")) {
        float value = float(trim(inString.substring(4)));

        // Skip only -512 values
        if (value != -512) {
          myGraph.addECG(value);
          println("E:" + value);  // for debugging
        } else {
          println("Skipped -512 ECG value");
        }
      } 
      else if (inString.startsWith("FSR:")) {
        float value = float(trim(inString.substring(4)));

        // Keep all FSR values
        myGraph.addFSR(value);
        println("F:" + value);  // for debugging
      } 
      else if (inString.equals("No-ECG-Data")) {
        println("ECG data missing!");
      } 
      else {
        println("Unknown line: " + inString);
      }
    } 
    catch(Exception e) {
      println("Invalid line: " + inString);
    }
  }
  delay(2);  // ~500 Hz update
}


  }
}


// -------------------- SerialGraph --------------------
class SerialGraph extends UIComponent {
  float[] ecgValues;
  float[] fsrValues;
  int headECG = 0;   // independent head index for ECG
  int headFSR = 0;   // independent head index for FSR
  float x, y, w, h;

  SerialGraph(float x, float y, float w, float h) {
    super(x, y, w, h);  // call UIComponent constructor
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    ecgValues = new float[int(w)];
    fsrValues = new float[int(w)];
  }

  // Add a new ECG value
  void addECG(float ecg) {
    synchronized(ecgValues) {
      ecgValues[headECG] = ecg;
      headECG = (headECG + 1) % ecgValues.length;
    }
  }

  // Add a new FSR value
  void addFSR(float fsr) {
    synchronized(fsrValues) {
      fsrValues[headFSR] = fsr;
      headFSR = (headFSR + 1) % fsrValues.length;
    }
  }

  void handleInput() {} // required by UIComponent

void display() {
  pushMatrix();
  translate(x, y);

  float fsrOffset = h - 100;

  // --- ECG Axis (Left) ---
  stroke(100);
  strokeWeight(1);
  line(0, 0, 0, h);  // left Y-axis
  line(0, h/2, w, h/2); // X baseline

  fill(0);
  textSize(12);
  textAlign(RIGHT, CENTER);
  text("550", -5, map(550, -512, 512, h, 0));
  text("0", -5, map(0, -512, 512, h, 0));
  text("-550", -5, map(-550, -512, 512, h, 0));

  // --- ECG Graph ---
  stroke(0, 255, 0);
  noFill();
  beginShape();
  for (int i = 0; i < ecgValues.length; i++) {
    int idx = (headECG + i) % ecgValues.length;
    float val = map(ecgValues[idx], -512, 512, h, 0);
    vertex(i, val);
  }
  endShape();

  // --- FSR Axis (Right) ---
  float axisX = w; // right side
  stroke(100);
  line(axisX, fsrOffset, axisX, fsrOffset + h); // right Y-axis

  textAlign(LEFT, CENTER);
  text("700", axisX + 5, fsrOffset + map(700, 0, 1023, h, 0));
  text("500", axisX + 5, fsrOffset + map(500, 0, 1023, h, 0));
  text("300", axisX + 5, fsrOffset + map(300, 0, 1023, h, 0));

  // --- FSR Graph ---
  stroke(0, 150, 255);
  noFill();
  beginShape();
  for (int i = 0; i < fsrValues.length; i++) {
    int idx = (headFSR + i) % fsrValues.length;
    float val = map(fsrValues[idx], 0, 1023, h, 0) + fsrOffset;
    vertex(i, val);
  }
  endShape();

  popMatrix();
}
}