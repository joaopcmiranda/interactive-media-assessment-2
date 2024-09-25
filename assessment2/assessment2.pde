SensorData sensorData;

void setup() {
  size(800, 800, P3D);
  sensorData = new SensorData();
  float[][] data = sensorData.Data("B12");//This is the function call
  println(data[0].length);  // This is test to print the first row of Oxygen data
  for(int i = 0;
  i <= sensorData.sampleSize - 1;
  i++) {
    println(data[0][i]);
  }

SensorDataObject d[] = new SensorDataObject[3];

  d[0] = new SensorDataObject(1, 1, data[0], data[1], data[2], data[3]);
  d[1] = new SensorDataObject(7, 2, data[0], data[1], data[2], data[3]);
  d[2] = new SensorDataObject(12, 3, data[0], data[1], data[2], data[3]);


  new ColorField(d, width, height);
}

void draw() {
}
