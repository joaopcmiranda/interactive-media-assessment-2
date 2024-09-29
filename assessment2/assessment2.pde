import controlP5.*;
import beads.*;
import java.io.File;
import java.util.ArrayList;
import java.text.SimpleDateFormat;
import java.util.Date;


PImage img, maskImg, bleachedImg;
color outlineColor = color(0, 0, 0);  // Black Outline
color backgroundColor = color(0, 0, 0, 0);  // Black background
color lungFillColor = color(0, 0, 0, 0);  // No fill
ControlP5 cp5;
SensorData sensorData;
ColorField colorField;
SoundController soundController; // Add SoundController reference
ArrayList<float[][]> data;
String keys[] = {"B05", "B06418", "B08", "B01", "B06419", "B07", "B08", "B04", "B11", "B12"};
int level[] = {  5, 6, 8, 1, 6, 7, 8, 4, 13, 11, 12};
int totalData = keys.length;  // Total number of data to fetch

// A list of threads for parallel fetching
ArrayList<FetchThread> threads = new ArrayList<FetchThread>();
//String floor = keys[1];

//for slider
float timePercentage = 0;
boolean pause = false;
boolean loadingComplete = false;  // Flag for loading completion
int loadedData = 0;  // Number of loaded data


void setup() {
  size(800, 800, P3D);
  background(0);
  PFont sliderF = createFont("arial", 15);
  cp5 = new ControlP5(this);

  // Initialize systems
  sensorData = new SensorData();
  data = new ArrayList<float[][]>();
  sensorData = new SensorData();
  soundController = new SoundController(); // Initialise SoundController

  // Start the data-fetching thread

  Thread fetchDataThread = new Thread(new Runnable() {

    public void run() {
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
      for (int i = 0; i < data.size();   i++) {
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
      bleachedImg = createImage(img.width, img.height, ARGB);
      // Apply the bleaching effect
      applyBleachEffect();
      //timeline slider

      cp5.addSlider("timePercentage") 
      .setLabel("Time") 
      .setValue(timePercentage) 
      .setPosition(width * 0.3, height - 100) 
      .setSize(int(width * 0.4), 30) 
      .setFont(sliderF) 
      .setColorActive(color(193, 20, 34, 230)) 
      .setColorForeground(color(90, 33, 51, 140)) 
      .setColorBackground(color(220, 150)) 
      .setRange(0, 1);

      loadingComplete = true;  // Data is loaded
    }
  }
  );

  fetchDataThread.start();  // Start the fetching thread
}

void draw() {
  if (!loadingComplete) {
    background(0);
    textAlign(CENTER);
    fill(255);
    text("Loading...", width / 2, height / 2);  // Draw loading text while data is being fetched

    // Calculate progress as a percentage
    float progress =(float)loadedData / totalData;

    // Draw the loading bar background
    fill(100);  // Gray color for the background of the loading bar
    rect(width * 0.25, height * 0.7, width * 0.5, 20);  // Draw the bar

    // Draw the progress bar
    fill(255, 0, 0);  // Red color for the progress bar
    rect(width * 0.25, height * 0.7, width * 0.5 * progress, 20);  // Scale the progress bar based on progress

    // Display progress percentage as text
    fill(255);
    text(int(progress * 100) + "%", width / 2, height * 0.75);

  } else {
    background(0);
    // Pause when space is pressed
    if (!pause) {
      timePercentage =(millis() % 10000) / 10000.0;
    }
    colorField.paintColorField(timePercentage);

    // Display the bleached image with the lung outline in 2D
    hint(DISABLE_DEPTH_TEST);  // Disable depth test to allow 2D drawing over 3D
    // Center the image on the canvas
    image(bleachedImg, (width - bleachedImg.width) / 2, (height - bleachedImg.height) / 2);
    hint(ENABLE_DEPTH_TEST);  // Re-enable depth test for future 3D drawings

    // Update slider value
    cp5.getController("timePercentage").setValue(timePercentage);
    colorField.heldDown();
    PFont fontT = createFont("arial", 13);
    textFont(fontT);
    textAlign(CENTER);
    text(sensorData.getTimeString(timePercentage) + "\nPause time with 'space'.", width / 2, height - 50);

    // Extract CO2 data from the first sensor and update the sound volume
    if (colorField.sensorData.length > 0) {
      float[] co2Data = colorField.sensorData[0].co2; // Get CO2 data from the first sensor
      float co2Level = co2Data[(int)(timePercentage *(co2Data.length - 1))]; // Get the CO2 level based on time
      soundController.updateVolume(co2Level); // Update the volume based on CO2 level
    }
    soundController.smoothVolume(); // Gradually change the actual volume
  }
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
    loadedData++;
  }
}

void keyPressed() {
  if (key == ' ') {
    pause = !pause;
  }
}

// Function to apply custom colors and bleach effect
void applyBleachEffect() {
  for (int x = 0;
    x < img.width;
    x++) {
    for (int y = 0;
      y < img.height;
      y++) {
      color c = img.get(x, y);
      // Check if the pixel is part of the lung outline(black) or background(white)
      if (brightness(c) > 50) {
        // Apply bleach to the background(custom color)
        bleachedImg.set(x, y, backgroundColor);  // Custom background color
      } else {
        // Fill the lung with a custom color and keep the outline
        if (brightness(c) < 50) {
          bleachedImg.set(x, y, outlineColor);  // Outline color
        } else {
          bleachedImg.set(x, y, lungFillColor);  // Fill the lungs with the desired color
        }
      }
    }
  }
}

