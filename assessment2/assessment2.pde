import controlP5.*;
import beads.*;
import java.io.File;
import java.util.ArrayList;

PImage img, maskImg, bleachedImg;
color outlineColor = color(0);  // Black for the outline
color backgroundColor = color(255, 255, 255);  // White for the bleached background
color lungFillColor = color(255, 182, 193);  // Light pink(example lung color)
ControlP5 cp5;
SensorData sensorData;
ColorField colorField;
SoundController soundController; // Add SoundController reference
ArrayList<float[][]> data;
String keys[] = {"B05", "B06418", "B08", "B01", "B06419", "B07", "B08", "B04", "B11", "B12"};
int level[] = { 5, 6, 8, 1, 6, 7, 8, 4, 13, 11, 12 };

// A list of threads for parallel fetching
ArrayList<FetchThread> threads = new ArrayList<FetchThread>();
//String floor = keys[1];

//for slider
float timePercentage =0;
boolean pause = false;



void setup() {
  size(800, 800, P3D);
  PFont sliderF = createFont("arial", 15);

  //timeline slider
  cp5 = new ControlP5(this);
  cp5.addSlider("timePercentage")
    .setLabel("Time")
    .setValue(timePercentage)
    .setPosition(width*0.3, height-100)
    .setSize(int(width*0.4), 30)
    .setFont(sliderF)
    .setColorActive(color(193, 20, 34, 230))
    .setColorForeground(color(90, 33, 51, 140))
    .setColorBackground(color(220, 150))
    .setRange(0, 1);
  sensorData = new SensorData();
  data = new ArrayList<float[][]>();
  sensorData = new SensorData();
  soundController = new SoundController(); // Initialise SoundController

  // Start parallel fetching for each key
  for (int i = 0; i < keys.length; i++) {
    FetchThread fetchThread = new FetchThread(keys[i], i);
    threads.add(fetchThread);
    fetchThread.start();
  }
  // Wait for all threads to finish fetching
  for (FetchThread thread : threads) {
    try {
      thread.join();  // Wait for this thread to finish
    }

    catch(InterruptedException e) {
      e.printStackTrace();
    }
  }
  // Once all threads are done, process the fetched data
  SensorDataObject[] d = new SensorDataObject[data.size()];
  for (int i = 0; i < data.size(); i++) {
    d[i] = new SensorDataObject(level[i], 0, data.get(i)[0], data.get(i)[1], data.get(i)[2], data.get(i)[3]);
  }
  colorField = new ColorField(d, width, height);

  // Load the lung image
  img = loadImage("image.png");  // Make sure this points to your file
  // Resize the image to fit within 800x800 canvas while maintaining aspect ratio
  img.resize(800, 0);  // Resize while keeping aspect ratio
  // Apply grayscale and threshold for the outline
  img.filter(GRAY);  // Convert to grayscale
  img.filter(THRESHOLD, 0.5);  // Apply threshold
  // Create a mask image for the bleach effect
  maskImg = img.copy();
  // Create the bleached background image
  bleachedImg = createImage(img.width, img.height, RGB);
  // Apply the bleaching effect
  applyBleachEffect();

}

void draw() {
  background(0);
  //pause when space is pressed
  if (!pause) {
    timePercentage =(millis() % 10000) / 10000.0;
  }
  colorField.paintColorField(timePercentage);

  //update slider value
  cp5.getController("timePercentage").setValue(timePercentage);
  colorField.heldDown();
  PFont fontT = createFont("arial", 13);
  textFont(fontT);
  textAlign(CENTER);
  text("Time is set as a fraction of the total duration.\nPause time with 'space'.", width/2, height-50);

  // extract CO2 data from the first sensor and update the sound volume
  if (colorField.sensorData.length > 0) {
    float[] co2Data = colorField.sensorData[0].co2; //get CO2 data from the first sensor
    float co2Level = co2Data[(int)(timePercentage * (co2Data.length - 1))]; //get the CO2 level based on time
    soundController.updateVolume(co2Level); //update the volume based on CO2 level
  }
  
  soundController.smoothVolume(); // gadually change the actual volume

  // Display the bleached image with the lung outline in 2D
  hint(DISABLE_DEPTH_TEST);  // Disable depth test to allow 2D drawing over 3D
  // Center the image on the canvas
  image(bleachedImg,(width - bleachedImg.width) / 2,(height - bleachedImg.height) / 2);
  hint(ENABLE_DEPTH_TEST);  // Re-enable depth test for future 3D drawings

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

void keyPressed() {
  if (key == ' ') {
    pause = !pause;
  }
}

// Function to apply custom colors and bleach effect
void applyBleachEffect() {
  for(int x = 0;
  x < img.width;
  x++) {
    for(int y = 0;
    y < img.height;
    y++) {
      color c = img.get(x, y);
      // Check if the pixel is part of the lung outline(black) or background(white)
      if (brightness(c) > 50) {
        // Apply bleach to the background(custom color)
        bleachedImg.set(x, y, backgroundColor);  // Custom background color
      } else {
        // Fill the lung with a custom color and keep the outline
        if (brightness(c) < 30) {
          bleachedImg.set(x, y, outlineColor);  // Outline color
        } else {
          bleachedImg.set(x, y, lungFillColor);  // Fill the lungs with the desired color
        }
      }
    }
  }
}
