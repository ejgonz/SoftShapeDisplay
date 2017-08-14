/* Animation
 *  Handles animation of shape display simulation.
 *  Author : Eric Gonzalez
 *  Date: Aug 11, 2017
 */
 
// Animation variables
ArrayList<ArrayList<PointMass>> keyFrames;
int keyframe = 0;
float animationRate = 0.3;
final int EDITING = 0;
final int ANIMATING = 1;
int currentState = EDITING;
boolean loopAnimation = false;

void animateDisplay() {
  println ("animating");
  float totalError = 0; 
  for (int i = 0; i < pointmasses.size(); i++) {
      PointMass p = pointmasses.get(i);
      PointMass k = keyFrames.get(keyframe).get(i);
     // Update error
     float diffX2 =  (p.x - k.x)*(p.x - k.x);
     float diffY2 =  (p.y - k.y)*(p.y - k.y);
     float diffZ2 =  (p.z - k.z)*(p.z - k.z);
     //float diffX2 = pointmasses.get(i).x;
     //float diffY2 = pointmasses.get(i).y;
     totalError += (diffZ2);
     //println(totalError);
     
     // Interpolate
     //p.x = lerp(p.x, k.x, animationRate);
     p.y = lerp(p.y, k.y, animationRate);
     p.z = lerp(p.z, k.z, animationRate);
   }
   
   // increase keyframe index if we reached the target
   if (totalError < 1) {
     println("keyframe completed: " + keyframe);
     keyframe++;
     if (loopAnimation && keyframe >= keyFrames.size()) keyframe = 0;
   }
}

ArrayList<PointMass> copyPointMassPositions(ArrayList<PointMass> m) {
  ArrayList<PointMass> copy = new ArrayList<PointMass>();
  for (int i = 0; i < m.size(); i++) {
    PointMass newPoint = new PointMass(m.get(i).x,m.get(i).y,m.get(i).z);
    copy.add(newPoint);
  }
  return copy;
}