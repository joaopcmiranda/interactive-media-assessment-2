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

  ColorField(SensorDataObject[] sensorData, int width, int height) {
    points = new PVector[sensorData.length];
    for (int i = 0; i < sensorData.length; i++) {
      float y = map(sensorData[i].level, -3, 15, 0, height);
      float x = random(0, 1) * width;
      points[i] = new PVector(x, y);
    }
    // print circles on the screen
    for (int i = 0; i < points.length; i++) {
      ellipse(points[i].x, points[i].y, 5, 5);
    }
  }

  void paintColorField(float timePercentage) {
    //This function will paint the color field onto the screens pixels
    //The color field will be a 2D grid of colors
    //The color of each cell will be determined by the sum of:
    // oxygen -> red 
    // co2 -> blue
    // hydrocarbon -> green
    // this will be done with the influence of each point in the grid
    // so each pixel is the average of the influence of all the points with a squared distance decay
    // data is in 0.0-1.0 range

    // for each pixel
    // for each point
    // calculate the influence
    // add the influence to the pixel
    // divide the pixel by the number of points
    

    // code below

    // for each pixel


  }
}
