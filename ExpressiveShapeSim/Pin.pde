// Pin
class Pin {
  PVector pos;       // position of front-left corner
  float pinWidth;    // side length
  float pinHeight;
  float maxHeight = 50; 
  ArrayList<PointMass> contains;
  
  // Constructor
  Pin(PVector pos, float pinWidth, float pinHeight) {
    this.pos = pos;
    this.pinWidth = pinWidth;
    this.pinHeight = pinHeight;
    
    contains = new ArrayList<PointMass>();
  }
  
  // Methods
  void updateHeight() {
    // Find pointmasses contained by pin
    findContainedPointMasses();
    
    if (contains.size() != 0) {
      // Get avg z of contained masses
      float sum = 0;
      for (PointMass cp : contains) {
        sum += cp.z;
      }
      pinHeight = sum/contains.size();
      
      // Constraints on height
      if (pinHeight > maxHeight)
        pinHeight = maxHeight;
      if (pinHeight < 0)
        pinHeight = 0;
    }
  }
  
  void findContainedPointMasses() {
    contains.clear();
    for(PointMass p : pointmasses) {
      if (containedInX(p) && containedInY(p))
        contains.add(p);
    }
  }
  
  boolean containedInX(PointMass p) {
    if (p.x > (pos.x - pinWidth/2) && p.x < (pos.x + pinWidth/2)) {
      return true;
    }
    return false;
  }
  
  boolean containedInY(PointMass p) {
    if (p.y > (pos.y - pinWidth/2) && p.y < (pos.y + pinWidth/2)) {
      return true;
    }
    return false;
  }
  
  // Draw
  void draw (){
    pushMatrix();
    translate(pos.x, pos.y, pos.z);                   // move to position
    translate(0, 0, pinHeight/2);   // offset for center of box
    //translate(-centroid.x,-centroid.y);               // offset from centroid
    rotateZ(-1*theta*DEG2RAD);
    box(pinWidth,pinWidth,pinHeight);
    popMatrix();
  }
}