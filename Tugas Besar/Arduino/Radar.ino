#include <Servo.h>

// Servo 360°
Servo myservo;
int servoPin = 9;

// Sensor ultrasonik
const int trigPin = 10;
const int echoPin = 11;

// Buzzer
const int buzzer = 3;

// Servo control
int direction = 1; // 1 = clockwise, -1 = counter-clockwise
unsigned long lastSwitchTime = 0;
const unsigned long moveDuration = 2250; // lama 1 putaran 360° penuh → sesuaikan dengan servomu

unsigned long currentTime;

long duration;
int distance;

void setup() {
  myservo.attach(servoPin);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(buzzer, OUTPUT);

  Serial.begin(9600);
  noTone(buzzer);
}

void loop() {
  currentTime = millis();

  // Ganti arah bila sudah selesai 1 putaran
  if (currentTime - lastSwitchTime >= moveDuration) {
    direction *= -1;
    lastSwitchTime = currentTime;
  }

  // Gerakkan servo 360°
  if (direction == 1) {
    myservo.write(117); // searah jarum jam
  } else {
    myservo.write(63);  // berlawanan arah jam
  }

  // Hitung sudut berdasarkan waktu
  unsigned long elapsed = currentTime - lastSwitchTime;
  float fraction = (float)elapsed / moveDuration;
  int angle;
  if (direction == 1) {
    angle = (int)(fraction * 360.0);  // 0 → 360
  } else {
    angle = 360 - (int)(fraction * 360.0); // 360 → 0
  }

  if (angle >= 360) angle = 359;  // Biar ga overflow

  distance = calculateDistance();
  updateBuzzer(distance);

  // Kirim ke Processing
  Serial.print(angle);
  Serial.print(",");
  Serial.print(distance);
  Serial.println(".");

  delay(100);
}

void updateBuzzer(int distance) {
  if (distance > 30) {
    noTone(buzzer);
  } else if (distance > 10) {
    tone(buzzer, 1000);
  } else {
    tone(buzzer, 500);
  }
}

int calculateDistance() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  duration = pulseIn(echoPin, HIGH, 23530);

  if (duration == 0) {
    return 400;
  } else {
    return duration * 0.034 / 2;
  }
}
