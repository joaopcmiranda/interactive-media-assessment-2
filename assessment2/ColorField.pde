class ColorField {
  // sensorData is a 2D array of floats
  // float[] dsOxygen = sensorData[0][];       // Oxygen data
  // float[] dsCo2 = sensorData[1][];          // CO2 data
  // float[] dsHydroCarbon = sensorData[2][];  // Hydrocarbon data
  ColorField(_, int width, int height) {
  }

  void paintColorField(float timeStamp) {
    //This function will paint the color field onto the screens pixels
    //The color field will be a 2D grid of colors
    //The color of each cell will be determined by the sum of:
    // oxygen -> red 
    // co2 -> blue
    // hydrocarbon -> green
    // this will be done with the influence of each point in the grid
    // so each pixel is the average of the influence of all the points with a squared distance decay
    // data is in 0.0-1.0 range

    getPixels();

    // for each pixel
    // for each point

    // calculate the influence
    // add the influence to the pixel
    // divide the pixel by the number of points
    // set the pixel color

    // draw the pixels

  }
}
