/* Transformation
 *  These funcitons handle the transformation of the mesh + pins. An affine transformation is used such that the display
 *  translates and rotates in the x-y plane (eventually according to position tracking of real world display)
 *  Author : Eric Gonzalez
 *  Date: Aug 18, 2017
 */

// Handles rotation of points about local centroid AND translation to ensure local centroid follows desired centroid location
void AffineTransform() {
  // We have the centroid coordinates already! 
  
  // Generate 3 x n matrix for initial points
  // x0  ...  xn
  // y0  ...  yn
  // 1   ...  1
  ArrayList<PointMass> points = new ArrayList<PointMass>();
  for (PointMass p : pointmasses) {
    // Store (x,y) for edges / pinned
    if (p.pinned || p.edge) {
      points.add(p);
    }
  }
  Matrix X = new Matrix(3,points.size());
  int n = 0;
  for (PointMass  p : points) {
    X.set(0,n,p.x);
    X.set(1,n,p.y);
    X.set(2,n,1);
    n++;
  }
  
  // grab current centroid 
  PVector currCentroid = FindCentroid();
  PVector translation2Centroid = new PVector(centroid.x - currCentroid.x, centroid.y - currCentroid.y);
  if ((centroid.y - currCentroid.y) < 1 & (centroid.y - currCentroid.y) > -1) translation2Centroid.y = 0;
  if ((centroid.x - currCentroid.x) < 1 & (centroid.x - currCentroid.x) > -1) translation2Centroid.x = 0;
  //println("Translation: " + translation2Centroid.x + " " + translation2Centroid.y);
  Matrix T = CreateTranslationMatrix(translation2Centroid);    // This matrix is used to ensure the current centroid overlaps with global centroid variable
  
  // Create affine transformation matrix
  //Matrix M = CreateTranformationMatrix(deltaTheta, t1x, t1y);
  float deltaTheta = 0;
  if (Math.floor(GetCurrentOrientation()) <= (((Math.floor(initTheta-theta) + 360) %360 ) - 1) ||  Math.floor(GetCurrentOrientation()) >= (((Math.floor(initTheta-theta) + 360) %360 ) + 1)){
    deltaTheta = (initTheta-theta) - GetCurrentOrientation();
  }
  Matrix M = CreateTranformationMatrix(deltaTheta*DEG2RAD, -centroid.x, -centroid.y);
  
  // Generate result
  Matrix Y = (M.times(T)).times(X);
  
  // Update point mass locations
  for (int i = 0; i < points.size(); i++) {
    points.get(i).pinX = Y.get(0,i);
    points.get(i).pinY = Y.get(1,i);
  }
    
  /*        
  
   * * * * Repeat the same process for pins * * *
   
   */
   
  // Generate 3 x n matrix for initial pin positions
  // x0  ...  xn
  // y0  ...  yn
  // 1   ...  1
  Matrix P = new Matrix(3,pins.size());
  n = 0;
  for (Pin  pin : pins) {
    P.set(0,n,pin.pos.x);
    P.set(1,n,pin.pos.y);
    P.set(2,n,1);
    n++;
  }
  
  // Find translation matrix
  PVector currPinCentroid = FindPinCentroid();
  PVector translation2PinCentroid = new PVector(centroid.x - currPinCentroid.x, centroid.y - currPinCentroid.y);
  if ((centroid.y - currPinCentroid.y) < 1 & (centroid.y - currPinCentroid.y) > -1) translation2PinCentroid.y = 0;
  if ((centroid.x - currPinCentroid.x) < 1 & (centroid.x - currPinCentroid.x) > -1) translation2PinCentroid.x = 0;
  //println("Translation: " + translation2Centroid.x + " " + translation2Centroid.y);
  Matrix T_P = CreateTranslationMatrix(translation2PinCentroid);    // This matrix is used to ensure the current centroid overlaps with global centroid variable
  
  // Create affine transformation matrix
  //Matrix M = CreateTranformationMatrix(deltaTheta, t1x, t1y);
  float deltaTheta_P = 0;
  if (Math.floor(GetCurrentPinOrientation()) <= (((Math.floor(initPinTheta-theta) + 360) %360 ) - 1) ||  Math.floor(GetCurrentPinOrientation()) >= (((Math.floor(initPinTheta-theta) + 360) %360 ) + 1)){
    deltaTheta_P = (initPinTheta-theta) - GetCurrentPinOrientation();
    println("HERE");
  }
  Matrix M_P = CreateTranformationMatrix(deltaTheta_P*DEG2RAD, -centroid.x, -centroid.y);
  
  // Generate result
  Matrix Y_P = (M_P.times(T_P)).times(P);
  
  // Update point mass locations
  for (int i = 0; i < pins.size(); i++) {
    pins.get(i).pos.x = Y_P.get(0,i);
    pins.get(i).pos.y = Y_P.get(1,i);
  }
}

// Creates 3 by 3 affine transformation matrix (rotation + translation)
// tx, ty are translation vector taking you to the origin
// adapted from: http://totologic.blogspot.com/2015/02/2d-transformation-matrices-baking.html
Matrix CreateTranformationMatrix(float theta, float tx, float ty) {
  float[][] temp = new float[3][3];
  float cRot = (float) Math.cos(theta);
  float sRot = (float) Math.sin(theta);
  
  // For translating back to point tx,ty
  float t2x = -tx;
  float t2y = -ty;

  temp[0][0] = cRot;
  temp[0][1] = -sRot;
  temp[0][2] = tx*cRot + ty*-sRot + t2x;
  temp[1][0] = sRot;
  temp[1][1] = cRot;
  temp[1][2] = tx*sRot + ty*cRot + t2y;
  temp[2][0] = 0.0;
  temp[2][1] = 0.0;
  temp[2][2] = 1.0;
  
  return new Matrix(temp);
}

// creates 3 by 3 translation matrix
Matrix CreateTranslationMatrix(PVector t){
   float[][] temp = new float[3][3];

  temp[0][0] = 1;
  temp[0][1] = 0;
  temp[0][2] = t.x;
  temp[1][0] = 0;
  temp[1][1] = 1;
  temp[1][2] = t.y;
  temp[2][0] = 0.0;
  temp[2][1] = 0.0;
  temp[2][2] = 1.0;
  
  return new Matrix(temp); 
}









// Deprecated
//  Now using 3x3 affine matrix transformation

//// Handles rotating of shape display about its center (z-axis only)
//void HandleRigidBodyRotation() {
//  //ResetShapeDisplayOrientation();
  
//  if (Math.floor(GetCurrentOrientation()) < (((Math.floor(initTheta-theta) + 360) %360 ) - 1) ||  Math.floor(GetCurrentOrientation()) > (((Math.floor(initTheta-theta) + 360) %360 ) + 1)){
//    println("rotating");
//    float deltaTheta = (initTheta-theta) - GetCurrentOrientation();
    
//    ArrayList<PointMass> edges = new ArrayList<PointMass>();
//    ArrayList<Float> xEdge = new ArrayList<Float>();
//    ArrayList<Float> yEdge = new ArrayList<Float>();
    
//    // For all Edge masses
//    for (PointMass p : pointmasses) {
//      // Store (x,y) for edges / pinned
//      if (p.pinned || p.edge) {
//        xEdge.add(p.x);
//        yEdge.add(p.y);
//        edges.add(p);
//      }
//    }
    
//    //  find center xc, yc (average edge points aka centroid)
//    //  we also use this loop to populate a 2D array of all edge points to rotate for creating a matrix with
//    int xSum = 0; 
//    int ySum = 0;
//    int numEdges = 0;
//    float [][] points2Rotate_Array = new float [2][xEdge.size()];
//    for (int i = 0; i < xEdge.size(); i++) {
//      // Get sums for finding center
//      if (edges.get(i).edge) {
//        xSum += xEdge.get(i);
//        ySum += yEdge.get(i);
//        numEdges++;
//      }
      
//      // Create 2D array of points
//      points2Rotate_Array[0][i] = xEdge.get(i);
//      points2Rotate_Array[1][i] = yEdge.get(i);
//    }
//    int numPoints = xEdge.size();
//    //println("numPoints = " + numPoints);
//    //println("numEdges = " + numEdges);
//    float xC = centroid.x;
//    float yC = centroid.y;
//    println("xC,yC: " + xC + "," + yC);
    
//    // Create 2-by-n matrix X of points to rotate
//    // | x0  x1  . . .  xn |
//    // | y0  y1  . . .  yn |
//    Matrix X = new Matrix(points2Rotate_Array);
    
//    // Create 2-by-n matrix C of center point
//    // | xC  xC  . . .  xC |
//    // | yC  yC  . . .  yC |
//    float [][] temp = new float [2][numPoints];
//    for (int n = 0; n < numPoints; n++) {
//      temp[0][n] = xC;
//      temp[1][n] = yC;
//    }
//    Matrix C = new Matrix(temp);
    
//    // Create 2-by-2cRotation Matrix
//    Matrix R = createRotationMatrix((deltaTheta)*DEG2RAD);
    
//    // Calculate resultant matrix of rotated points
//    // Xrot = R*(X-C) + C
//    Matrix Xrot = (R.times(X.minus(C)).plus(C));
    
//    // Update point mass locations
//    for (int i = 0; i < numPoints; i++) {
//      edges.get(i).pinX = Xrot.get(0,i);
//      edges.get(i).pinY = Xrot.get(1,i);
//    }
    
//    // Repeat exact same for all pins
//  }
//}

//// Creates 2 by 2 rotation matrix
//Matrix createRotationMatrix(float theta) {
//  float[][] temp = new float[2][2];
//  temp[0][0] = (float) Math.cos(theta);
//  temp[1][1] = temp[0][0];
//  temp[1][0] = (float) Math.sin(theta);
//  temp[0][1] = -1*temp[1][0];
//  return new Matrix(temp);
//}

//// Determine offset vector (x,y only) of each edge mass (or pinned mass) from centroid.
//// With these offsets, edges can always be reset to 0 deg rotatation relative to centroid!
//void DetermineOffsets(){
//  offsets = new ArrayList<PVector>();
  
//  // Determine the vector offset of each mass
//  for (PointMass p : pointmasses) {
//    if (p.edge) {    // or pinned too?
//      PVector offset = new PVector(p.x - centroid.x,p.y - centroid.y);
//      offsets.add(offset);
//    }
//  }
//}