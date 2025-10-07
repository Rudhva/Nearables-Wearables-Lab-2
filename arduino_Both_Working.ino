const int ECG_PIN = A0;
const int RESP_PIN = A1;
const int LO_PLUS = 11;
const int LO_MINUS = 10;

void setup() {
  Serial.begin(115200);
  pinMode(LO_PLUS, INPUT);
  pinMode(LO_MINUS, INPUT);
}

void loop() {
  int ecgVal = analogRead(ECG_PIN);
  int respVal = analogRead(RESP_PIN);

  bool leadsOff = digitalRead(LO_PLUS) || digitalRead(LO_MINUS);

  if (leadsOff) Serial.println("No-ECG-Data");
  else Serial.print("ECG: "); Serial.println(ecgVal-512);

  delay(1);

  Serial.print("FSR: "); Serial.println(respVal);

  delay(1); // tiny delay
}
