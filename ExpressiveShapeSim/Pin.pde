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
    if (p.x > pos.x && p.x < (pos.x + pinWidth)) {
      return true;
    }
    return false;
  }
  
  boolean containedInY(PointMass p) {
    if (p.y > pos.y && p.y < (pos.y + pinWidth)) {
      return true;
    }
    return false;
  }
  
  // Draw
  void draw (){
    pushMatrix();
    translate(pos.x, pos.y, pos.z);                   // move to position
    translate(pinWidth/2, pinWidth/2, pinHeight/2);   // offset for center of box
    box(pinWidth,pinWidth,pinHeight);
    popMatrix();
  }
}