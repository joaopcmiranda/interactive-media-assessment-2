import java.util.HashMap;
import java.util.*;
  HashMap<String,String> buildingSensor =new HashMap<String,String>();
HashMap<String,String> sensorName =new HashMap<String,String>();
String keys[]={"B06418","B08","B01","B06419","B07","08","04","13","11"};
String values[]={
"ES_B_06_418_7BED",
"ES_B_08_423_7BE2",
"ES_B_01_411_7E39",
"ES_B_06_419_7C09",
"ES_B_07_420_7E1D",
"ES_B_04_415_7BD1",
"ES_B_08_422_7BDC",
"ES_C_13_302_C88E",
"ES_B_11_428_3EA4"
};
String subSensor[]={"HUMA","CO2","VOC","O2"};



String UrlData(String passedBuildingSensor,String passedSensorName){
  
  String building_Sensor=buildingSensor.get(""+passedBuildingSensor);
  String sensor_Name=sensorName.get(""+passedSensorName);
  String url = "https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2024-08-01T00%3A00&rToDate=2024-08-01T23%3A59&rFamily=wasp&rSensor="+building_Sensor+"&rSubSensor="+sensor_Name+"";
  
  return url;
}

void Data(String buildingNum,String value){
 


for (int i = 0; i <= values.length-1; i++) {
     buildingSensor.put(keys[i],values[i]);
}
for(int i=0 ;i<=subSensor.length-1;i++){
  sensorName.put(subSensor[i],subSensor[i]);
}

}


void setup() {
  // Initialize the data
  Data("", ""); // This will populate the HashMaps
  
  // Test UrlData by passing valid buildingSensor and sensorName values
  String testUrl = UrlData("B06418", "HUMA");
  
  // Print the returned URL to check if it's constructed properly
  println("Generated URL: " + testUrl);
}

void draw() {
  // Your draw code if needed
}
