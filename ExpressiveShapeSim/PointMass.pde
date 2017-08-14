// PointMass
class PointMass {
  float lastX, lastY, lastZ; // for calculating position change (velocity)
  float x,y,z;
  float accX, accY, accZ;
  
  float mass = 1;
  float damping = damp;

  // An ArrayList for links, so we can have as many links as we want to this PointMass
  ArrayList links = new ArrayList();
  
  boolean pinned = false;
  boolean edge = false;
  boolean grabbed = false;
  boolean grabbable = false;
  float pinX, pinY, pinZ;
  
  
  // PointMass constructor
  PointMass(float xPos, float yPos, float zPos) {
    x = xPos;
    y = yPos;
    z = zPos;
    
    lastX = x;
    lastY = y;
    lastZ = z;
    
    accX = 0;
    accY = 0;
    accZ = 0;
  }
  
  // The update function is used to update the physics of the PointMass.
  // motion is applied, and links are drawn here
  void updatePhysics(float timeStep) { // timeStep should be in elapsed seconds (deltaTime)
    this.applyForce(0, 0, mass * gravity * gravityScale); 
    
    float velX = x - lastX;
    float velY = y - lastY;
    float velZ = z - lastZ;
    
    // dampen velocity
    velX *= 0.99;
    velY *= 0.99;
    velZ *= 0.99;

    float timeStepSq = timeStep * timeStep;
    
    damping = damp;
    // calculate the next position using Verlet Integration
    float nextX = x + velX*(1 - damping) + 0.5 * accX * timeStepSq;
    float nextY = y + velY*(1 - damping) + 0.5 * accY * timeStepSq;
    float nextZ = z + velZ*(1 - damping) + 0.5 * accZ * timeStepSq;
    
    // reset variables
    lastX = x;
    lastY = y;
    lastZ = z;
    
    x = nextX;
    y = nextY;
    z = nextZ;
    
    accX = 0;
    accY = 0;
    accZ = 0;
  }
  
  void updateInteractions() {
    //float distanceSquared = (mouseX-screenX(x,y,z))*(mouseX-screenX(x,y,z)) + (mouseY-screenY(x,y,z))*(mouseY-screenY(x,y,z));
       
    if (grabbed && mousePressed) {
         // keep x, y same. move z up
         lastX = x;
         lastY = y;
         lastZ = z + (mouseY-clickY)*mouseInfluenceScalar;
    } else if (!mousePressed) {
         grabbed = false;
    }
    else if ((mousePressed && (mouseButton == RIGHT)) && !keyPressed) {
      if (grabbable){
         // unpin and don't grab
         pinned = false;
      }
    }
  }

  void draw() {
    // draw the links and points
    stroke(0);
    strokeWeight(6);
    if (grabbed) stroke(120,0,0);
    else if (grabbable) stroke(120,120,0);
    else if (pinned && !edge) stroke(0,120,0);
    point(x, y, z);
    if (links.size() > 0) {
      for (int i = 0; i < links.size(); i++) {
        Link currentLink = (Link) links.get(i);
        currentLink.draw();
      }
    }
  }
  
  /* Constraints */
  void solveConstraints() {
    /* Link Constraints */
    // Links make sure PointMasss connected to this one is at a set distance away
    for (int i = 0; i < links.size(); i++) {
      Link currentLink = (Link) links.get(i);
      currentLink.solve();
    }
    

    /* Other Constraints */
    // make sure the PointMass stays in its place if it's pinned
    if (pinned || edge) {
      x = pinX;
      y = pinY; 
      z = pinZ;
    } 
    
    // Make sure point masses don't dip below the floor
    if (z < 0) z = 0;
    
  }
  
  // attachTo can be used to create links between this PointMass and other PointMasss
  void attachTo(PointMass P, float restingDist, float stiff) {
    attachTo(P, restingDist, stiff, true);
  }
  void attachTo(PointMass P, float restingDist, float stiff, float tearSensitivity) {
    attachTo(P, restingDist, stiff, true);
  }
  void attachTo(PointMass P, float restingDist, float stiff, boolean drawLink) {
    Link lnk = new Link(this, P, restingDist, stiff, drawLink);
    links.add(lnk);
  }
  void removeLink (Link lnk) {
    links.remove(lnk);
  }  
 
  void applyForce(float fX, float fY, float fZ) {
    // acceleration = (1/mass) * force
    // or
    // acceleration = force / mass
    accX += fX/mass;
    accY += fY/mass;
    accZ += fZ/mass;
  }
  
  void pinTo (float pX, float pY, float pZ) {
    pinned = true;
    pinX = pX;
    pinY = pY;
    pinZ = pZ;
  }
} 