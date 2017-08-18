/* ExpressiveShapeSim
 *  Main script for expressive shape simulation.
 *  Author : Eric Gonzalez
 *  Date: Aug 11, 2017
 */

/* TODO:
 * - move GUI stuff into separate file                           [X]
 * - remove any tear stuff                                       [X]
 * - move camera stuff into separate file                        [X]
 * - create state machine for edit and animation modes           [X]
 * - move interaction stuff into separate file (grabbable, etc.) [X]
 * - serial data out to physical display                         [X]
 * - read and send setup slave files                             [X]
 * - Implement rotation of base using RotationMatrix             [X]
 * - implement communcation with unity                           [ ]
 * - import position and rotation from Vive                      [ ]
 * - paint stiffness with independent control                    [ ]
 * - implement linear animation controls                         [ ]
 * - fix issue with rotations during animation                   [ ]
 * - explore other forces beyond gravity                         [ ]
 */

import peasy.*;                // Camera
import controlP5.*;            // GUI
import processing.serial.*;    // Serial out

final boolean displayCentroid = true;

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
PVector centroid;             // center of rotation
float initTheta;              // Initial orientation (centroid to point (0,0))

// Rotation Variables & Constants
float theta = 0;    // Deg
float lastTheta = 0;
final float DEG2RAD = (float) Math.PI/180.00;

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
  centroid = FindCentroid();
  initTheta = GetCurrentOrientation();
  //DetermineOffsets();
  
  // init keyframes
  keyFrames = new ArrayList<ArrayList<PointMass>>();
  
  // Set up slaves
  SetupSlaves();
  
  frameRate(120);
  println("Initial Theta: " + initTheta);
}

void draw() {
  background(#f2f2f2);
  drawAxes(200);
  gui();
 
  switch (currentState) {
    case EDITING:
      determineInteractionRegion();
      HandleArrowKeyMovement ();
      //HandleRigidBodyRotation();  // maybe having a moving variable?
      AffineTransform();
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
  
  //println("Current Orientation: " + Math.floor(GetCurrentOrientation()) +" Desired Theta: " + Math.floor((initTheta-theta)+360)%360);
  //println("Delta: " + ((initTheta-theta) - GetCurrentOrientation()));
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
    pushMatrix();
    translate(centroid.x,centroid.y);
    rotateZ(-theta*DEG2RAD);              // QUICK FIX. NOT ROBUST. SHOULD USE ROTATION MATRICES, ETC.
    stroke(100);
    fill(200); //fill(#f2f2f2);
    for (Pin pin : pins) {
      pin.draw();
    }
    popMatrix();
    fill(0);
  }
  
  if (displayCentroid) {
    pushMatrix();
    stroke(#ff0000);
    fill(#ff0000);
    translate(centroid.x, centroid.y);
    sphere(2);
    stroke(100);
    popMatrix();
  }
}

// Generate mesh and pins of shape display
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

// Find Centroid of shape display
//   Takes the average coordinate of the edge pointmasses
PVector FindCentroid() {
  int xSum = 0;
  int ySum = 0;
  int numEdges = 0;
  for (PointMass p : pointmasses) {
    if (p.edge) {
      xSum += p.x;
      ySum += p.y;
      numEdges++;
    }
  }
  return new PVector(xSum/numEdges,ySum/numEdges);
}

// Returns current orientation of the display in deg, 
// defined as the angle between +x axis and vector from centroid to corner pointmass initially at 0,0 
// *(0,0)
//  \  < neg. theta
//   \     v
//    C . . . .  +x
//    .
//    +y
float GetCurrentOrientation() {
  return ( ((float) Math.atan2(pointmasses.get(0).y - centroid.y, pointmasses.get(0).x - centroid.x) * (1/DEG2RAD)) + 360) % 360;
}

/* Simple Helpers */
void printPointMasses(ArrayList<PointMass> masses) {
  for (PointMass p : masses) {
    println("x: " + p.x + " y: " + p.y + " z: " + p.z);
  }
}