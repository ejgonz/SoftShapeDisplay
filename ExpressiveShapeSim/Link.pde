// The Link class is used for handling distance constraints between PointMasses.
class Link {
  float restingDistance;
  float stiffness;
  
  PointMass p1;
  PointMass p2;
  
  // if you want this link to be invisible, set this to false
  boolean drawThis = true;
  
  Link(PointMass which1, PointMass which2, float restingDist, float stiff, boolean drawMe) {
    p1 = which1; // when you set one object to another, it's pretty much a reference. 
    p2 = which2; // Anything that'll happen to p1 or p2 in here will happen to the paticles in our ArrayList
    
    restingDistance = restingDist;
    stiffness = stiff;
    drawThis = drawMe;

  }
  
  // Solve the link constraint
  void solve() {
    // calculate the distance between the two PointMasss
    float diffX = p1.x - p2.x;
    float diffY = p1.y - p2.y;
    float diffZ = p1.z - p2.z;
    float d = sqrt(diffX * diffX + diffY * diffY + diffZ * diffZ);
    
    // find the difference, or the ratio of how far along the restingDistance the actual distance is.
    float difference = (restingDistance - d) / d;
    
    stiffness = stiffnesses;
    // Inverse the mass quantities
    float im1 = 1 / p1.mass;
    float im2 = 1 / p2.mass;
    float scalarP1 = (im1 / (im1 + im2)) * stiffness;
    float scalarP2 = stiffness - scalarP1;
    
    // Push/pull based on mass
    // heavier objects will be pushed/pulled less than attached light objects
      p1.x += diffX * scalarP1 * difference;
      p1.y += diffY * scalarP1 * difference;
      p1.z += diffZ * scalarP1 * difference;
    
      p2.x -= diffX * scalarP2 * difference;
      p2.y -= diffY * scalarP2 * difference;
      p2.z -= diffZ * scalarP2 * difference;
      
      // Make sure position constraints are enforced
      if (p1.edge || p1.pinned) {
        p1.x = p1.pinX;
        p1.y = p1.pinY;
        p1.z = p1.pinZ;
      }
      
      if (p2.edge || p2.pinned) {
        p2.x = p2.pinX;
        p2.y = p2.pinY;
        p2.z = p2.pinZ;
      }
  }

  // Draw if it's visible
  void draw() {
    if (drawThis)
      strokeWeight(1);
      line(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z);
  }
}