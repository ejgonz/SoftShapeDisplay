/* Network
 *  Handles data transfer between Processing and Unity.
 *  Author : Eric Gonzalez
 *  Date: Aug 18, 2017
 *
 *  oscP5 library by Andreas Schlegel
 *  oscP5 website at http://www.sojamo.de/oscP5
 */



void setupNetwork() {
  // Set up our broadcast on a port Unity listens to
  oscP5 = new OscP5(this, 57131);                           // listener
  myRemoteLocation = new NetAddress("127.0.0.1", 57130);    // sender
}


void oscEvent(OscMessage theOscMessage) {
  if (useUnity) {
    //println("### received an osc message with addrpattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
    theOscMessage.print();
    
    if (theOscMessage.checkAddrPattern("/viveData")) {
      float x = (float) theOscMessage.arguments()[0];
      float y = (float) theOscMessage.arguments()[1];
      float rot = (float) theOscMessage.arguments()[2];
      
      // Assign values
      centroid.x = x*2;
      centroid.y = y*2;
      theta = -1*rot;
    }
  }
}