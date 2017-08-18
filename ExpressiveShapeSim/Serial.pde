/* Serial
 *  Functions for handling Serial communication with shape display.
 *  Author : Eric Gonzalez
 *  Date: Aug 11, 2017
 */
 
  // Data sending variables
  // Display automatic refresh rate
  int refreshRate = 8; //[ms]
  int sendCount;
  float sendRate;

  // Enable sending data to hw at fixed rate
  boolean automaticSending = false;
  float counter;
  boolean setupSlaves = false;
  boolean refreshDisplay = false;    //true if there is pos data to send
  boolean resetDisplay = false;
  boolean stopDisplay = false;
  long lastTimeSerial = 0;

  // Message commands
  final int DataCMD  = 127;
  final int ZeroCMD  = 126;
  final int StopCMD  = 125;
  final int SetupCMD = 124;

  // slave setup commands
  final int SET_KP             =  253;
  final int SET_KI             =  248;
  final int SET_KD             =  247;
  final int SET_LOWERINGSPEED  =  246;
  final int DISABLE_PIN        =  245;
 
// Setup
void SetupSerial() {
  println("Available Serial Ports");
  printArray(Serial.list());
  serialPort = new Serial(this,Serial.list()[1],115200);
  println("Selected: " + Serial.list()[1]);
}

// Send
void SendData() {
  long currTime = millis();  
  if (automaticSending) {
      counter -= (currTime - lastTimeSerial); //decrement counter
      // if counter done, send the data
      if (counter < 0) {
        thread("UpdateShapeDisplay");
        sendCount++;
        counter = refreshRate;
      }
      
      // print send rate
      if (sendCount>0) print("Send Rate: " + (millis()-startSendTime)/sendCount + " ms \r");
    }
   lastTimeSerial = currTime;
}

// Update
void UpdateShapeDisplay() {
  // First send the command byte so Teensy knows we are sending data
    int val2send = DataCMD;
    char data2send = (char)val2send;

    serialPort.write( str(data2send) );

    // Now send the rest of the data
    for (Pin pin : pins)
    {
      val2send = (int)(pin.pinHeight);
      data2send = (char) val2send;
      serialPort.write( str(data2send) );
    }
}

// Stop
void StopShapeDisplay() {
    // Send the stop command byte 
    int val2send = StopCMD;
    char data2send = (char) val2send;
    serialPort.write( str(data2send) );
}

// Zero
void ZeroShapeDisplay() {
    // Send the zero command byte 
    int val2send = ZeroCMD;
    char data2send = (char) val2send;
    serialPort.write( str(data2send) );
}
// SetupSlaves
  private void SetupSlaves() {

    // Grab directory
    String currDir = sketchPath();
    String path = currDir + "/SlaveParameters";
    File[] files = listFiles(path);
    //println("Listing all filenames in Slave Parameters directory: ");
    //printArray(files);

    // For each file in "SlaveParameters" folder
    for (int i = 0; i < files.length; i++) {
     // Load file
      File f = files[i];
   
      // Check type
      String [] temp = split(f.getName(),'.');
      String fileType = temp[temp.length-1];
      //println(fileType);
      if (!fileType.equals("txt")) continue;
      
      // Import
      String [] lines = loadStrings(f.getAbsolutePath());
      //println("Loaded " +f.getName());
      boolean emptyfile = false;
      
      // Read first line (SlaveID)
      int index = 0;
      String line = lines[index];
      //println("[Line " + index + "]: " + line);
      
      // Handle comments or newlines
      while (line.length() == 0 || line.charAt(0) == '#') {  
        index++;
        if (index < lines.length)
          line = lines[index++]; 
        else {
          emptyfile = true;
          break;
        }
      }
      if (emptyfile) continue;  // skip to next file if this one had no data
      
      // Parse ID
      // Expected line format --> Slave: 55
      int colonIndex = line.indexOf(": ");
      String parsedID = line.substring(colonIndex + 2);
      int ID = Integer.parseInt(parsedID);
      index++;

      // Read command lines
      while (index < lines.length) {
        line = lines[index];
        println("[Line " + index + "]: " + line);
        // Handle comments or new lines
        if (line.length() == 0 || line.charAt(0) == '#') { 
          index++;
          continue;
        }

         // Expected line format --> Command[string], pin[int < 6], value[int < 255]
         String [] parsed = split(line,',');
         String parsedCmd = trim(parsed[0]);   // from start to first comma
         String parsedPin = trim(parsed[1]);   // between middle commas
         String parsedVal = trim(parsed[2]);   // from second comma to end
         
         int cmd = 0;
         int pin, val;

          // Parse command
          if (parsedCmd.toLowerCase().equals("kp"))
          {
            cmd = SET_KP;
          }
          else if (parsedCmd.toLowerCase().equals("ki"))
          {
            cmd = SET_KI;
          }
          else if (parsedCmd.toLowerCase().equals("kd"))
          {
            cmd = SET_KD;
          }
          else if (parsedCmd.toLowerCase().equals("ls"))
          {
            cmd = SET_LOWERINGSPEED;
          }
          else if (parsedCmd.toLowerCase().equals("disable"))
          {
            cmd = DISABLE_PIN;
          }
          else
          {
            String err = "Error: Unknown command in Slave ID " + parsedID;
            println(err);
            index++;
            continue;
          }

          pin = Integer.parseInt(parsedPin);
          val = Integer.parseInt(parsedVal);

          // Send message 
          byte[] msg = { (byte)SetupCMD, (byte)ID, (byte)cmd, (byte)pin, (byte)val };
          serialPort.write(msg);
          //println();
          //println("Sent bytes:");
          //printArray(msg);
          //println();
          
          // increase file index
          index++;
       }
     }
  }
  
// Print
void printHeights() {
  int countZeros = 0;
  int i = 0;
  for (Pin pin : pins) {
    println("[" + i + "] " + pin.pinHeight);
    i++;
    
    if (pin.pinHeight == 0)
      countZeros++;
  }
  //println("zeros: " + countZeros);
}