/*  Interaction
 *    Handles all mouse and keyboard interactions;
 *  Author : Eric Gonzalez
 *  Date: Aug 11, 2017
 */

// Mouse variables
boolean alreadyPressed = false;
int clickX, clickY;
boolean mouseOffDisplay = true;
boolean altDown;

// Interaction variables
float mouseInfluenceSize = 5;       // masses within this many pixels of the cursor will be targeted
float interactionRadius = 30;       // determines how many neighbors of target will be interacted with
float mouseInfluenceScalar = 0.5;   // how much will mouse movement affect display when interacting?

// keyboard movement
long lastTime = 0;
float moveVelocity = 0.05;

/* Handle Inputs */
void keyPressed() {
  if ((key == 'r') || (key == 'R')) {
    pointmasses = new ArrayList<PointMass>();
    createShapeDisplay();
  } 
  if ((key == 'g') || (key == 'G'))
    toggleGravity();
  if (keyCode == SHIFT)
    shiftDown = true;
  if (keyCode == CONTROL)
    altDown = true;
  
  // Animation
  if (key == 'k' || key == 'K') {
    //keyFrames.add(pointmasses);
    keyFrames.add(copyPointMassPositions(pointmasses));
    printPointMasses(keyFrames.get(keyFrames.size()-1));
  }
  if (key == 'c' || key == 'C') {
    keyFrames.clear();
    keyframe = 0;
  }
  if (key == 'a' || key == 'A') {
    currentState = ANIMATING;
    keyframe = 0;
  }
  if (key == 'e' || key == 'E') {
    currentState = EDITING;
    keyframe = 0;
  }
  
  // Serial Communication
  if (key == 'u' || key == 'U') {
    // update shape display once
    UpdateShapeDisplay();
  }
  if (key == 'z' || key == 'Z') {
    // zero display
    automaticSending = false;
    ZeroShapeDisplay();
  }
  if (key == 's' || key == 'S') {
    // turn on/off autosend
    automaticSending = !automaticSending;
    startSendTime = millis();
    sendCount = 0;
  }
  if (key == 'p' || key == 'P') {
    // print pin heights
    printHeights();
  }
  if (key == 'x' || key == 'X') {
    // stop display
    automaticSending = false;
    StopShapeDisplay();
  }
}

void toggleGravity() {
  if (gravity != 0)
    gravity = 0;
  else
    gravity = 980;
}

void keyReleased() {
  if (keyCode == SHIFT) {
    shiftDown = false;
  }
  if (keyCode == CONTROL)
    altDown = false;
}

void mousePressed() {
  // 
  if (!keyPressed) {
    clickY = mouseY;
    if( mouseButton == LEFT) {
//   Cycle through all point masses
      for (PointMass p : pointmasses) {
        if (p.grabbable){           
            // unpin and grab
            p.pinned = false;
            if (!p.edge) p.grabbed = true;
        }
      }
    }
  }
}

void mouseReleased() {
  // pin any points that were grabbed
  if (!keyPressed) {
    for (PointMass p : pointmasses) {
        if (p.grabbed) p.pinTo(p.x,p.y,p.z);
        }
  }
}

// Determines which masses will be interacted with based on mouse position.
void determineInteractionRegion() {
    mouseOffDisplay = true;
    for (PointMass p : pointmasses) {
      // Check if in interaction area
      float distanceSquared = (mouseX-screenX(p.x,p.y,p.z))*(mouseX-screenX(p.x,p.y,p.z)) + (mouseY-screenY(p.x,p.y,p.z))*(mouseY-screenY(p.x,p.y,p.z));
        if (distanceSquared < mouseInfluenceSize) { // remember mouseInfluenceSize was squared in setup()
          mouseOffDisplay = false;
          // Mark neighbors as grabbable
          for (PointMass n : pointmasses) {
            float neighborDist = sqrt((p.x-n.x)*(p.x-n.x) + (p.y-n.y)*(p.y-n.y));
            if (neighborDist <= interactionRadius) {
              n.grabbable = true;
            }
            else {
              n.grabbable = false;
            }
          }
      }
    }
    // Clear grabbables if mouse is not over shape display
    if (mouseOffDisplay) {
      clearInteractionRegion();
    }
}

void clearInteractionRegion() {
  for (PointMass p : pointmasses) {
    p.grabbable = false;
  }
}

// Arrowkey move commands
void HandleArrowKeyMovement () {
  long thisTime = millis();
  
  // Move in -Y
  if (keyPressed && keyCode == UP){
    // Move all pins
    for (Pin pin : pins) {
      pin.pos.y += -1*moveVelocity*(thisTime - lastTime);
    }
    // Move centroid
    centroid.y += -1*moveVelocity*(thisTime - lastTime);
  }
  
  // Move in +Y
  if (keyPressed && keyCode == DOWN) {
    // Move all pins
    for (Pin pin : pins) {
      pin.pos.y += moveVelocity*(thisTime - lastTime);
    }
    // Move centroid
    centroid.y += moveVelocity*(thisTime - lastTime);
  }
  
  // Move in +X
  if (keyPressed && keyCode == RIGHT) {
    // Move all pins
    for (Pin pin : pins) {
      pin.pos.x += moveVelocity*(thisTime - lastTime);
    }
    // Move centroid
    centroid.x += moveVelocity*(thisTime - lastTime);
  }
  
  // Move in -X
  if (keyPressed && keyCode == LEFT) {
    // Move all pins
    for (Pin pin : pins) {
      pin.pos.x += -1*moveVelocity*(thisTime - lastTime);
    }
    // Move centroid
    centroid.x += -1*moveVelocity*(thisTime - lastTime);
  }
  
  // rotations
  if (keyPressed && key == '1') {
    // increase theta
    theta++;
  }
  if (keyPressed && key == '2') {
    // decrease theta
    theta--;
  }
  
  lastTime = thisTime;
}