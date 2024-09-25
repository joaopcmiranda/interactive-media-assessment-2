SensorData sensorData;
ColorField colorField;
ArrayList<float[][]> data;
String keys[] = {"B05","B06418","B08","B01","B06419","B07","B08","B04","B11","B12"};
int level[] = { 5, 6, 8, 1, 6, 7, 8, 4, 13, 11, 12 };

// A list of threads for parallel fetching
ArrayList<FetchThread> threads = new ArrayList<FetchThread>();

void setup() {
  size(800, 800, P3D);
  sensorData = new SensorData();
  data = new ArrayList<float[][]>();

  // Start parallel fetching for each key
  for(int i = 0;  i < keys.length;  i++) {
    FetchThread fetchThread = new FetchThread(keys[i], i);
    threads.add(fetchThread);
    fetchThread.start();
  }
  // Wait for all threads to finish fetching
  for(FetchThread thread : threads) {
    try {
      thread.join();  // Wait for this thread to finish
    }

    catch(InterruptedException e) {
      e.printStackTrace();
    }
  }
  // Once all threads are done, process the fetched data
  SensorDataObject[] d = new SensorDataObject[data.size()];
  for(int i = 0; i < data.size();  i++) {
    d[i] = new SensorDataObject(level[i], 0, data.get(i)[0], data.get(i)[1], data.get(i)[2], data.get(i)[3]);
  }
  colorField = new ColorField(d, width, height);
}

void draw() {
  background(0);
  float timePercentage =(millis() % 10000) / 10000.0;
  colorField.paintColorField(timePercentage);
}

// Thread class to fetch data in parallel
class FetchThread extends Thread {
  String key;
  int index;

  FetchThread(String key, int index) {
    this.key = key;
    this.index = index;
  }

  public void run() {
    println("Fetching data for " + key);
    float[][] result = sensorData.Data(key);

    synchronized(data) {
      data.add(result);  // Add fetched data to the shared list
    }
    println("Data fetched for " + key);
  }
}
