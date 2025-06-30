import processing.serial.*;

// Komunikasi Serial
Serial myPort;

String data = "";
String angle = "";
String distance = "";  
int iAngle = 0, iDistance = 0;

float pixsDistance;
String statusObjek;

void setup() {
  size(1200, 700);
  smooth();
 String portName = "COM6";
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('.');
}

void draw() {
  // Fade efek
  fill(0, 10);
  noStroke();
  rect(0, 0, width, height - height * 0.065);

  fill(98, 245, 31); // Warna hijau neon
  drawRadar();
  drawLine();
  drawObject();
  drawText();
}

void serialEvent(Serial myPort) {
  data = myPort.readStringUntil('.');
  if (data != null) {
    data = trim(data);
    int idx = data.indexOf(",");
    if (idx > 0) {
      angle = data.substring(0, idx);
      distance = data.substring(idx + 1);
      try {
        iAngle = int(angle);
        iDistance = int(distance);
      } catch (Exception e) {
        println("Format error: " + data);
      }
    }
  }
}

void drawRadar() {
  pushMatrix();
  translate(width/2, height/2);
  noFill();
  strokeWeight(2);
  stroke(98, 245, 31);

  // Lingkaran jarak
  for (int i = 1; i <= 4; i++) {
    float d = i * 150;
    ellipse(0, 0, d, d);
  }

  // Garis radial setiap 30°
  for (int ang = 0; ang < 360; ang += 30) {
    float x = 150 * 2 * cos(radians(ang));
    float y = 150 * 2 * sin(radians(ang));
    line(0, 0, x, y);
  }

  popMatrix();
}

void drawLine() {
  pushMatrix();
  translate(width/2, height/2);
  strokeWeight(2);
  stroke(30, 250, 60);
  float x = 300 * cos(radians(iAngle));
  float y = 300 * sin(radians(iAngle));
  line(0, 0, x, y);
  popMatrix();
}

void drawObject() {
  if (iDistance > 400) return;

  // Konversi jarak dari cm ke pixel (0-40 cm → 0-300 px)
  pixsDistance = map(iDistance, 0, 40, 0, 300);

  // Jangan gambar jika sudah melebihi radius radar (300 pixel)
  if (pixsDistance > 300) return;

  pushMatrix();
  translate(width/2, height/2);
  stroke(255, 10, 10);
  strokeWeight(9);

  float x = pixsDistance * cos(radians(iAngle));
  float y = pixsDistance * sin(radians(iAngle));
  point(x, y);
  popMatrix();
}


void drawText() {
  fill(0);
  noStroke();
  rect(0, height - height * 0.0648, width, height);

  fill(98, 245, 31);
  textSize(25);
  text("10cm", width - width * 0.3854, height - height * 0.0833);
  text("20cm", width - width * 0.281, height - height * 0.0833);
  text("30cm", width - width * 0.177, height - height * 0.0833);
  text("40cm", width - width * 0.0729, height - height * 0.0833);

  textSize(40);
  text("Radar 360°", width - width * 0.875, height - height * 0.0277);
  text("Sudut: " + iAngle + "°", width - width * 0.48, height - height * 0.0277);
  text("Jarak: " + iDistance + " cm", width - width * 0.26, height - height * 0.0277);

  if (iDistance > 100) {
    statusObjek = "Di Luar Jangkauan";
  } else {
    statusObjek = "Dalam Jangkauan";
  }
  textSize(30);
  text("Status: " + statusObjek, width - width * 0.65, height - height * 0.06);
}
