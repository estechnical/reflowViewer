/*
 * ESTechnical Reflow Viewer
 * For use with the ESTechnical Reflow Controller for T962/T962A and toaster oven conversions
 * Based on original work by Sofian Audry (info@sofianaudry.com) (Oscilliscope with processing and arduino)
 * Adapted by Ed Simmons (2014) 
 * ed@estechnical.co.uk
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import processing.serial.*;
import java.io.BufferedWriter;
import java.io.FileWriter;

String outFilename = "/home/ed/reflowLog.csv"; // edit this to choose where to save datalogging output
String serialPort = "/dev/ttyUSB0"; // edit this to suit... 

Serial port;  // Create object from Serial class
int cycleTime, cycleState, heaterValue, fanValue;// Data received from the serial port
double setpoint, temp1, temp2 ;

int[]  heaterValues, fanValues; // arrays for drawing graph
double[] setpoints, temp1s, temp2s;
float zoom;

void setup() 
{
  size(1280, 480);
  background(0);
  drawLegend();
  fill(255, 255, 255);
  text("No data", width/2-40, height/2+8);

  // Open the port that the board is connected to and use the same speed
  print(Serial.list());
  port = new Serial(this, serialPort, 57600);
  setpoints = new double[width];
  heaterValues = new int[width];
  fanValues = new int[width];
  temp1s = new double[width];
  temp2s = new double[width];

  zoom = 1.0f;
  smooth();
}

/**
 * Appends text to the end of a text file located in the data directory, 
 * creates the file if it does not exist.
 * Can be used for big files with lots of rows, 
 * existing lines will not be rewritten
 */
void appendTextToFile(String filename, String text) {
  File f = new File(dataPath(filename));
  if (!f.exists()) {
    createFile(f);
  }
  try {
    PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
    out.println(text);
    out.close();
  }
  catch (IOException e) {
    e.printStackTrace();
  }
}

/**
 * Creates a new file including all subfolders
 */
void createFile(File f) {
  File parentDir = f.getParentFile();
  try {
    parentDir.mkdirs(); 
    f.createNewFile();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}   


int getY(int val) {
  return (int)(height - val / 300.0f * (height - 1));
}

int getY(double val) {
  return (int)(height - val / 300.0f * (height - 1));
}


boolean getValues() {
  int value = -1;
  String inBuffer = "";
  while (port.available () > 0) { // each time we find data, we read all of it!
    String in = port.readString();   
    if (in != null) {
      //println("Got data:" + in);
      inBuffer = inBuffer +""+ in;
      //println("inBuffer:"+inBuffer);
    }
    if (inBuffer.charAt(inBuffer.length()-1) == '\n') {
      println("got a whole line:" + inBuffer);
      appendTextToFile(outFilename, inBuffer.substring(0,inBuffer.length()-1));
      String[] tokens = splitTokens(inBuffer, ",");
      if (tokens.length == 7) {
        cycleTime = int(tokens[0]);
        cycleState = int(tokens[1]);
        setpoint = float(tokens[2]);
        heaterValue = int(tokens[3]);
        fanValue = int(tokens[4]);
        temp1 = float(tokens[5]);
        temp2 = float(tokens[6]);
        if (temp1 >= 300.0) {
          print("Warning, high temp1 detected: ");
          print(temp1);
          println("C");
        }
        if (temp2 >= 300.0) {
          print("Warning, high temp2 detected: ");
          print(temp2);
          println("C");
        }
      }
      return false; // success
    }
  }
  return true;
}

void pushValues() {
  for (int i=0; i<width-1; i++) {

    setpoints[i] = setpoints[i+1];
    heaterValues[i] = heaterValues[i+1];
    fanValues[i] = fanValues[i+1];
    temp1s[i] = temp1s[i+1];
    temp2s[i] = temp2s[i+1];
  }
  setpoints[width-1] = setpoint;
  heaterValues[width-1] = heaterValue;
  fanValues[width-1] = fanValue;
  temp1s[width-1] = temp1;
  temp2s[width-1] = temp2;
}

void drawGraph() {
  stroke(255);

  int displayWidth = (int) (width / zoom);

  int k = setpoints.length - displayWidth;// array index counter variable

  int x0 = 0;
  int setpoint0 = getY(setpoints[k]); // get the oldest reading
  int heaterValue0 = getY(heaterValues[k]);
  int fanValue0 = getY(fanValues[k]);
  int temp1_0 = getY(temp1s[k]);
  int temp2_0 = getY(temp2s[k]);

  for (int i=1; i<displayWidth; i++) {
    k++; 
    int x1 = (int) (i * (width-1) / (displayWidth-1));
    int setpoint1 = getY(setpoints[k]);
    int heaterValue1 = getY(heaterValues[k]);
    int fanValue1 = getY(fanValues[k]);
    int temp1_1 = getY(temp1s[k]);
    int temp2_1 = getY(temp2s[k]);
    stroke(200, 0, 0);
    line(x0, setpoint0, x1, setpoint1);
    stroke(255, 0, 0);
    line(x0, heaterValue0, x1, heaterValue1);
    stroke(0, 255, 0);
    line(x0, fanValue0, x1, fanValue1);
    stroke(255, 127, 127);
    line(x0, temp1_0, x1, temp1_1);
    stroke(127, 255, 127);
    line(x0, temp2_0, x1, temp2_1);
    x0 = x1;
    setpoint0 = setpoint1;
    heaterValue0 = heaterValue1;
    fanValue0 = fanValue1;
    temp1_0 = temp1_1;
    temp2_0 = temp2_1;
  }
}

void drawLegend() {

  // blue temp grid lines every 20 degrees
  stroke(0, 0, 127);
  for (int grid = 20; grid < 300; grid+=20) {
    line(0, getY(grid), width, getY(grid));
    text(""+grid+"°C", 10, getY(grid)-2);
  }

  // lead free solder melting point
  stroke(127, 0, 0);
  line(0, getY(217), width, getY(217));
  fill(0, 102, 153);
  text("pB Free", 50, getY(217)-2);

  if (cycleTime !=0) { // during an active reflow cycle...
    fill(127, 127, 127);
    String state = "";
    switch(cycleState) {
    case 1:
      state = "Ramp to soak";
      break;
    case 2:
      state = "Soak";
      break;
    case 3:
      state = "Ramp to peak";
      break;
    case 4:
      state = "Peak";
      break;
    case 5:
      state = "Ramp down";
      break;
    case 6:
      state = "Cool down";
      break;
    }
    int y = 0;
    fill(200, 200, 200);
    text("Reflow cycle active, elapsed time " + cycleTime/1000 + "S", width/2 - 25, y+20);
    text(state, width/2 - 25, y+40);
    text("Temp set point: " + nf((float)setpoint, 3, 1) +"°C", width/2 - 25, y+60);
    text("Temp 1: " +  nf((float)temp1, 3, 1) +"°C", width/2 - 25, y+80);
    text("Temp 2: " +  nf((float)temp2, 3, 1) +"°C", width/2 - 25, y+100);
    text("Heater: " +  heaterValue + "%", width/2 - 25, y+120);
    text("Fan: " +  fanValue + "%", width/2 - 25, y+140);
  } 
  else {
    fill(200, 200, 200);
    text("Idle", width/2 - 25, 20);
  }
}

void keyReleased() {
  switch (key) {
  case '+':
    zoom *= 2.0f;
    println(zoom);
    if ( (int) (width / zoom) <= 1 )
      zoom /= 2.0f;
    break;
  case '-':
    zoom /= 2.0f;
    if (zoom < 1.0f)
      zoom *= 2.0f;
    break;
  }
}

void draw()
{


  boolean ret = getValues();
  if (!ret) {
    background(0);
    drawLegend();

    pushValues();
    drawGraph();
  }
  delay(250);
}

