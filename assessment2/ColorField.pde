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
    for(int i = 0;  i < sensorData.length;  i++) {
      float y = map(sensorData[i].level, -3, 18, 0, height);
      float x = random(0, 1) * width;
      points[i] = new PVector(x, y);
    }
  }

  void paintColorField(float timePercentage) {
    loadPixels();

    for(int i = 0; i < points.length; i++) {
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
