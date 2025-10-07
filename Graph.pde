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
    float fsrBase = 500; // middle baseline
    while (true) {
      // Simulated ECG waveform (spikes with noise)
      float ecg = sin(t * TWO_PI * 2) * 0.7 + random(-0.05, 0.05);
      if (random(1) < 0.02) ecg = 1.0; // occasional spike (heartbeat)
      
      // Simulated slow FSR breathing waveform
      float fsr = fsrBase + 200 * sin(t * TWO_PI / 5.0);
      
      myGraph.addECG(ecg);
      myGraph.addFSR(fsr);
      
      t += 0.01;
      delay(10); // controls update rate (~100 Hz)
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

void display() {
  pushMatrix();
  translate(x, y);

  // baseline
  stroke(255, 0, 0, 50);
  line(0, h/2, w, h/2);  // middle of graph

  // ECG
  stroke(0, 255, 0);
  noFill();
  beginShape();
  for (int i = 0; i < ecgValues.length; i++) {
    int idx = (headECG + i) % ecgValues.length;

    // Map ECG from -500..500 to 0..h (invert Y for Processing)
    float val = map(ecgValues[idx], -500, 500, h, 0);
    vertex(i, val);
  }
  endShape();

  // FSR
  stroke(0, 150, 255);
  noFill();
  beginShape();
  for (int i = 0; i < fsrValues.length; i++) {
    int idx = (headFSR + i) % fsrValues.length;

    // Map FSR from 0..1023 to 0..h (invert Y for Processing)
    float val = map(fsrValues[idx], 0, 1023, h, 0);
    vertex(i, val);
  }
  endShape();

  popMatrix();
}

  void handleInput() {} // required by UIComponent
}







class ECGFilter {
  // === Internal state for filters ===
  float prevRaw = 0;          // previous raw ECG sample for HPF
  float prevHPF = 0;          // previous HPF output
  float prevEMA = 0;          // previous EMA output
  float alphaEMA = 0.05;      // smoothing factor for EMA

  // For median filter
  int medianWindow = 5;
  float[] buffer;
  int bufferIndex = 0;
  int bufferSize;

  // Constructor
  ECGFilter(int windowSize) {
    bufferSize = windowSize;
    buffer = new float[bufferSize];
    for (int i = 0; i < bufferSize; i++) buffer[i] = 0;
  }

  // === Entry point ===
  float cleanData(float sample) {
    float value = sample;

    // --- Baseline removal / High-pass filter ---
    // comment out to disable
    value = highPassFilter(value);

    // --- Median filter ---
    // comment out to disable
    value = medianFilter(value);

    // --- EMA / Low-pass smoothing ---
    // comment out to disable
    value = emaFilter(value);

    return value;
  }

  // === High-pass filter (baseline wander removal) ===
  float highPassFilter(float x) {
    float R = 0.995;
    float y = x - prevRaw + R * prevHPF;
    prevRaw = x;
    prevHPF = y;
    return y;
  }

  // === EMA / low-pass filter ===
  float emaFilter(float x) {
    float y = alphaEMA * x + (1 - alphaEMA) * prevEMA;
    prevEMA = y;
    return y;
  }

  // === Median filter for spike removal ===
  float medianFilter(float x) {
    buffer[bufferIndex] = x;
    bufferIndex = (bufferIndex + 1) % bufferSize;

    float[] temp = new float[bufferSize];
    arrayCopy(buffer, temp);
    java.util.Arrays.sort(temp);
    return temp[bufferSize / 2];
  }
}
