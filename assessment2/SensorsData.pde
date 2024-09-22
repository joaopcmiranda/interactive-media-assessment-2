
import java.util.HashMap;
import java.util.*;


public class SensorData{
//========================================================================================================================================================================================================
//Declarations Start
private String subSensor[];
private Table oxygenTable;
private Table co2Table;
private Table hydrocarbonTable;
private Table humidityTable;
public int sampleSize=200;//increase this number to get more rows
private float [] dsHumidity=new float[sampleSize];
private float [] dsOxygen=new float[sampleSize];
private float [] dsCo2=new float[sampleSize];
private float [] dsHydroCarbon=new float[sampleSize];
//float oxygenValue[],co2Value[],hydrocarbonValue[],humidityValue[];
private HashMap<String,String> buildingSensor =new HashMap<String,String>();
private String keys[]={"B05","B06418","B08","B01","B06419","B07","B08","B04","B13","B11","B12","B15"};
private String values[]={
 "ES_B_05_416_7C15",
"ES_B_06_418_7BED",
"ES_B_08_423_7BE2",
"ES_B_01_411_7E39",
"ES_B_06_419_7C09",
"ES_B_07_420_7E1D",
"ES_B_04_415_7BD1",
"ES_B_08_422_7BDC",
"ES_C_13_302_C88E",
"ES_B_11_428_3EA4",
"ES_B_12_431_7BC2"
};
//String subSensor[]={"O2","CO2","VOC","HUMA"};
//========================================================================================================================================================================================================
//Declaration End

public SensorData() {
        // Initialize building sensors map
        for (int i = 0; i < values.length; i++) {
            buildingSensor.put(keys[i], values[i]);
        }
    }
/*Processing URL based on the Building Number and Sensor Name
The var passedBuildingSensor and passed SensorName can be confusing but they are
basically what we passed in our data function, but i wanted URL processing to be outside
and not in the actual function
*/
//API CALL URL FUNCTION
//========================================================================================================================================================================================================
public String urlData(String passedBuildingSensor,String passedSensorName){
  
   String building_Sensor = buildingSensor.get(passedBuildingSensor);
 // String sensor_Name=sensorName.get(""+passedSensorName);
  String url = "https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2024-08-01T00%3A00&rToDate=2024-08-30T23%3A59&rFamily=wasp&rSensor="+building_Sensor+"&rSubSensor="+passedSensorName+"";  
  return url;
}
//========================================================================================================================================================================================================
// pass the value array to be downSampled
public float[] downSample(float originalData[],int newSize ){
 
  float [] result=new float[newSize];
  float factor = float(originalData.length)/newSize;
  
  for(int i=0; i<= newSize-1;i++){
  int newData= int(i*factor);
  result[i]=originalData[newData];
  
  }
  return result;
}

//Start of data function
//========================================================================================================================================================================================================
//This is the actual function which will be called in the main Function
public float[][] Data(String buildingNum)
/*Here we need to pass BuildingNumber which is 
"B06418","B08","B01","B06419","B07","08","04","13","11"
the function is gonna return arrays of floats and integers with values in it
TimeStamp|O2|Co2|VOC|HUM
*/
{
  subSensor = new String[]{"O2", "CO2", "VOC", "HUMA"};
  
for (int i = 0; i <= values.length-1; i++) {
     buildingSensor.put(keys[i],values[i]);
}
 oxygenTable=loadTable(urlData(buildingNum,subSensor[0]),"header,csv"); 
 co2Table=loadTable(urlData(buildingNum,subSensor[1]),"header,csv");
 hydrocarbonTable=loadTable(urlData(buildingNum,subSensor[2]),"header,csv");
 humidityTable=loadTable(urlData(buildingNum,subSensor[3]),"header,csv");
float[] oxygenValue = new float[oxygenTable.getRowCount()];
float[] co2Value = new float[co2Table.getRowCount()];
float[] hydrocarbonValue = new float[hydrocarbonTable.getRowCount()];
float[] humidityValue = new float[humidityTable.getRowCount()];
//Getting O2 Values
 for(int i =0; i<=(oxygenTable.getRowCount())-1;i++){
    
   oxygenValue[i]=((((oxygenTable.getFloat(i,1))/100)*1000)-0.4)/0.318;
   
 }
 
 //Getting Co2 Values from the Table
 for(int i =0; i<=(co2Table.getRowCount())-1;i++){
    
    float deltaEMF=(((0.355/7)-(co2Table.getFloat(i,1))/7)*1000);//  Calculate EMF
   double co2Conc= Math.pow(10,(deltaEMF+163.4)/64.25);/*(25*deltaEMF)+350;// Calculate Conc*/
    
    co2Value[i]=(float)co2Conc;//Put Conc in the Value array
  //println(co2Value[i]);
 }
//Getting values for Hypocarbons Value lower than 10ppm is good
  for(int i =0; i<=(hydrocarbonTable.getRowCount())-1;i++){
    float sensorResistance = 0;
    float hcTableValue=hydrocarbonTable.getFloat(i,1);
    float normalResistance=0;
    sensorResistance = (100/(2.5-hcTableValue))*hcTableValue;
    normalResistance = sensorResistance/100;//Considering ideal room temperature of 20 degree and 50% Humindity
    double concResult = Math.pow(10, (0.09721 - Math.log10(normalResistance))) / 0.6483;
   
    hydrocarbonValue[i]=(float)concResult;
    
    
  //println(hydrocarbonValue[i]);
 }

//Getting values for Humidity
for(int i =0; i<=(humidityTable.getRowCount())-1;i++){
    humidityValue[i] = humidityTable.getFloat(i,1);  
  //println(humidityValue[i]);
  
 }
 
 dsHumidity=downSample(humidityValue,sampleSize);
  dsHydroCarbon=downSample(hydrocarbonValue,sampleSize);
   dsOxygen=downSample(oxygenValue,sampleSize);
    dsCo2=downSample(co2Value,sampleSize);

      float[][] result = new float[4][200];
      result[0]=dsOxygen;
      result[1]=dsCo2;
      result[2]=dsHydroCarbon;
      result[3]=dsHumidity;
      
      //println(result[0]);
     return result;
 }
 /* The function will return a 2d array having 4 rows and 200 columns 
 Each first row that is 
 result[0][i]======>Oxygen Values
 result[1][i]======>CO2 Values
 result[2][i]======>Hydrocarbon Values
 result[3][i]======>Humidity Values
 
//=======================================================================================================|| 
//Use the following Format to get the desired Data                                                       ||
                                                                                                         ||
 SensorData sensor= new SensorData();                                                                    ||
 float[][] sensorData = sensor.Data("B06418");  // Pass the desired building number as an argument       ||
                                                                                                         ||
// Access the sensor data (oxygen, CO2, hydrocarbons, humidity)                                          ||
float[] dsOxygen = sensorData[0][];       // Oxygen data                                                   ||
float[] dsCo2 = sensorData[1][];          // CO2 data                                                      ||
float[] dsHydroCarbon = sensorData[2][];  // Hydrocarbon data                                              ||
float[] dsHumidity = sensorData[3][];     // Humidity data                                                 ||
                                                                                                         ||
//=======================================================================================================||
 
 when calling this function remember to make a 2d array and store all the values in that 2d array.
 
 
 */


//void setup() {
//  // Initialize the data
//  Data("B05"); // This will populate the HashMaps
  
//  // Test UrlData by passing valid buildingSensor and sensorName values
//  //String testUrl = urlData("B06418", "HUMA");
  
//  // Print the returned URL to check if it's constructed properly
//  //println("Generated URL: " + testUrl);
//}

//void draw() {
//  // Your draw code if needed
//}
}
