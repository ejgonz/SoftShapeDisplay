/* ExpressiveShapeSim
 *  Main script for expressive shape simulation.
 *  Author : Eric Gonzalez
 *  Date: Aug 11, 2017
 */


/* TODO:
 * - move GUI stuff into separate file                           [X]
 * - remove any tear stuff                                       [X]
 * - make positions into Pvec type instead sep, x,y,z            [ ]
 * - move camera stuff into separate file                        [X]
 * - create state machine for edit and animation modes           [X]
 * - move interaction stuff into separate file (grabbable, etc.) [X]
 * - serial data out to physical display                         [X]
 * - read and send setup slave files                             [X]
 * - import position and rotation from Vive                      [ ]
 * - paint stiffness with independent control                    [ ]
 */

import peasy.*;                // Camera
import controlP5.*;            // GUI
import processing.serial.*;    // Serial out

// Where we'll store all of the points and pins
ArrayList<PointMass> pointmasses;
ArrayList<Pin> pins;

// amount to accelerate everything downward
float gravity = 980;
float gravityScale = 1;

// Dimensions for ShapeDisplay.
//   Pins
final int dispWidthPins = 12;   // x pins
final int dispLengthPins = 24;  // y pins
final float pinSpacing = 3;     // mm
final float pinWidth = 4.76;    // mm
final int densityScalar = 2;    // # of point masses rel to pins
//   PointMasses
final int dispWidth = dispWidthPins*densityScalar;      // x pointmasses
final int dispLength = dispLengthPins* densityScalar;   // y pointmasses
final int yStart = 0; // where will the display start on the y axis?
final float restingDistances = (pinWidth+pinSpacing)/densityScalar - 0.1;
float stiffnesses = 0.5;
float damp = 0.2;

// Display
boolean showPins = true;
boolean showMesh = true;

// GUI
ControlP5 cp5;

// Camera
PeasyCam camera;
boolean shiftDown = false;

// Physics, see physics.pde
Physics physics;

// Serial
Serial serialPort;
long startSendTime;

void setup() {
  size(640,480, P3D);
  
  // Serial
  SetupSerial();
  
  // Camera control
  camera = new PeasyCam(this, 50, 50, 0, 180);
  
  // GUI
  setupGUI();
  
  // Init physics
  physics = new Physics();
  
  // we square the mouseInfluenceSize so we don't have to use squareRoot when comparing distances with this.
  mouseInfluenceSize *= mouseInfluenceSize; 
  
  pointmasses = new ArrayList<PointMass>();
  pins = new ArrayList<Pin>();
  
  // create the display
  createShapeDisplay();
  
  // init keyframes
  keyFrames = new ArrayList<ArrayList<PointMass>>();
  
  // Set up slaves
  SetupSlaves();
}

void draw() {
  background(#f2f2f2);
  drawAxes(200);
  gui();
  switch (currentState) {
    case EDITING:
      determineInteractionRegion();
      HandleArrowKeyMovement ();
      physics.update();
      break;
      
    case ANIMATING:
      if (keyframe < keyFrames.size()){
        animateDisplay();
      }
      break;
  }
  camera.setActive(shiftDown);
  UpdatePins();
  updateGraphics();
  SendData();
}

void UpdatePins() {
  for (Pin pin : pins) {
    pin.updateHeight();
  }
}

/* Draw everything */
void updateGraphics() {
  if (showMesh){
    for (PointMass p : pointmasses) {
     p.draw();
    }
  }
  
  if (showPins) {
    // Grey with black outline
    stroke(100);
    fill(200); //fill(#f2f2f2);
    for (Pin pin : pins) {
      pin.draw();
    }
    fill(0);
  }
}

/* Generate mesh and pins of shape display */
void createShapeDisplay() {
  // Create "sheet" of point masses
  int midWidth = 0;
  for (int y = 0; y <= dispLength; y++) { // due to the way PointMasss are attached, we need the y loop on the outside
    for (int x = 0; x <= dispWidth; x++) { 
      PointMass pointmass = new PointMass(midWidth + x * restingDistances, y * restingDistances + yStart, 0);
      
      // attach to 
      // x - 1  and
      // y - 1  
      //  *<---*<---*<-..
      //  ^    ^    ^
      //  |    |    |
      //  *<---*<---*<-..
      //
      // PointMass attachTo parameters: PointMass PointMass, float restingDistance, float stiffness
      if (x != 0) 
        pointmass.attachTo((PointMass)(pointmasses.get(pointmasses.size()-1)), restingDistances, stiffnesses);
      // the index for the PointMasss are one dimensions, 
      // so we convert x,y coordinates to 1 dimension using the formula y*width+x  
      if (y != 0)
        pointmass.attachTo((PointMass)(pointmasses.get((y - 1) * (dispWidth+1) + x)), restingDistances, stiffnesses);
      
      // we pin the edge PointMassses to where they are
      if ((y == 0 || x == 0) || (x == dispWidth || y == dispLength)) {
        pointmass.pinTo(pointmass.x, pointmass.y, 0);
        pointmass.edge = true;
      }
        
      // add to PointMass array  
      pointmasses.add(pointmass);
    }
  }
  
  // Create pins
  for (int x = 0; x < dispWidthPins; x++) {
    for (int y = 0; y < dispLengthPins; y++) {
      PVector pinpos = new PVector(x*(pinWidth + pinSpacing),y*(pinWidth + pinSpacing),0);
      Pin pin = new Pin(pinpos, pinWidth,10);
      pins.add(pin);
    }
  }
  
}

/* Helpers */
void addPointMass(PointMass p) {
  pointmasses.add(p); 
}

void removePointMass(PointMass p) {
  pointmasses.remove(p);  
}

void printPointMasses(ArrayList<PointMass> masses) {
  for (PointMass p : masses) {
    println("x: " + p.x + " y: " + p.y + " z: " + p.z);
  }
}