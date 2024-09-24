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
}

void draw() {
  // rotate a 3d cube in space
  background(255);
  translate(width / 2, height / 2, 0);
  rotateX(frameCount * 0.01);
  rotateY(frameCount * 0.01);
  box(200);
}
