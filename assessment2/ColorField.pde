class SensorDataObject {
  int level;
  int number;
  float[] o2;
  float[] co2;
  float[] hydrocarbon;
  float[] humidity;

  SensorDataObject(int level, int number, float[] o2, float[] co2, float[] hydrocarbon, float[] humidity) {
    this.level = level;
    this.number = number;
    this.o2 = o2;
    this.co2 = co2;
    this.hydrocarbon = hydrocarbon;
    this.humidity = humidity;
  }
}
class ColorField {
  PVector[] points;
  SensorDataObject[] sensorData;

  ColorField(SensorDataObject[] sensorData, int width, int height) {
    this.sensorData = sensorData;
    this.points = new PVector[sensorData.length];
    for (int i = 0; i < sensorData.length; i++) {
      float y = map(sensorData[i].level, -3, 18, 0, height);
      float x = random(0, 1) * width;
      points[i] = new PVector(x, y);
    }
  }

  //see values when holding down
  void heldDown() {
    for (int i = 0; i<points.length; i++) {
      //this was to see where the points were
      //rect(points[i].x, points[i].y, 5, 5);
      float sX = points[i].x;
      float sY = points[i].y;
      float o2 = sensorData[i].o2[(int)(timePercentage *(sensorData[i].o2.length - 1))];
      float co2 = sensorData[i].co2[(int)(timePercentage *(sensorData[i].co2.length -1))];
      float hydrocarbon = sensorData[i].hydrocarbon[(int)(timePercentage *(sensorData[i].hydrocarbon.length - 1))];
      float humidity = sensorData[i].humidity[(int)(timePercentage *(sensorData[i].humidity.length - 1))];
      int level = sensorData[i].level;
      PFont font = createFont("arial", 15);
      
      // see values box and text
      if (mousePressed&&(abs(sX-mouseX)*abs(sX-mouseX)+ abs(sY-mouseY)*abs(sY-mouseY) <= 50*50) ) {
        float mw = 140;
        float mh = 120;
        float mx = constrain(mouseX-3+mw/2, 30+mw/2, width-30-mw/2);
        float my = constrain(mouseY-4-(mh)/2, 30+mh/2, height-30-mh/2);
        float tx = constrain(mouseX+mw/60, 30+mw/24, width-30-mw+mw/24);
        float ty = constrain(mouseY-mh/3-4-(mh)/2, 30+(mh*1.5)/10, height-(mh)/3-30-mh/2);

        //println(my, mx);
        rectMode(CENTER);
        fill(150, 180);
        stroke(140, 180);
        rect(mx, my, mw, mh, 10);
        fill(240);
        textLeading(5);
        textFont(font);
        String shownText = "Level: "+level+"\nOxygen: "+ nf(o2, 0, 2) +"\nCo2: "+ nf(co2, 0, 2) +"\nHydroCarbon: "+ nf(hydrocarbon, 0, 2)+"\nHumidity: "+ nf(humidity, 0, 2);
        text(shownText, tx, ty);
        rectMode(CORNER);
        fill(255, 255);
      }
    }
  }

  void paintColorField(float timePercentage) {
    loadPixels();

    for (int i = 0; i < points.length; i++) {
      float x = points[i].x;
      float y = points[i].y;

      float o2 = sensorData[i].o2[(int)(timePercentage *(sensorData[i].o2.length - 1))];
      float co2 = sensorData[i].co2[(int)(timePercentage *(sensorData[i].co2.length -1))];
      float hydrocarbon = sensorData[i].hydrocarbon[(int)(timePercentage *(sensorData[i].hydrocarbon.length - 1))];

      // previous timePercentage for averaging
      if ((int)((timePercentage) * (sensorData[i].o2.length - 1)) > 0) {
        float o2p = sensorData[i].o2[(int)((timePercentage) *(sensorData[i].o2.length - 1)) - 1];
        float co2p = sensorData[i].co2[(int)((timePercentage) *(sensorData[i].co2.length - 1))- 1];
        float hydrocarbonp = sensorData[i].hydrocarbon[(int)((timePercentage) *(sensorData[i].hydrocarbon.length - 1))- 1];

        o2 = (o2 + o2p) / 2;
        co2 = (co2 + co2p) / 2;
        hydrocarbon = (hydrocarbon + hydrocarbonp) / 2;
      }
      // next timePercentage for averaging
      if ((int)((timePercentage) *(sensorData[i].o2.length - 1)) + 1 < sensorData[i].o2.length) {
        float o2n = sensorData[i].o2[(int)((timePercentage) *(sensorData[i].o2.length - 1)) + 1];
        float co2n = sensorData[i].co2[(int)((timePercentage) *(sensorData[i].co2.length - 1))+ 1];
        float hydrocarbonn = sensorData[i].hydrocarbon[(int)((timePercentage) *(sensorData[i].hydrocarbon.length - 1))+ 1];

        o2 = (o2 + o2n) / 2;
        co2 = (co2 + co2n) / 2;
        hydrocarbon = (hydrocarbon + hydrocarbonn) / 2;
      }

      float r = map(o2, 0, 3.0, 0, 255);
      float b = map(co2, 0, 2000.0, 0, 255);
      float g = map(hydrocarbon, 0, 10.0, 0, 255);

      for (int j=0; j<width; j++) {
        for (int k=0; k<height; k++) {
          int index = j + k * width;

          // square decay using the distance from the current pixel to the current point
          float distance = dist(x, y, j, k) / 150;
          float decay = (1.0 /(1.0 + distance*distance)) / points.length;

          pixels[index] += color(r * decay, 0, b * decay, g * decay);
        }
      }
    }
    updatePixels();
  }
}
