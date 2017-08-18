/* GUI Stuff 
 *   Handles all GUI setup and interface arrangement.
 *  Author : Eric Gonzalez
 *  Date: Aug 11, 2017
 */
 
void gui() {
  hint(DISABLE_DEPTH_TEST);
  camera.beginHUD();
  cp5.draw();
  textSize(10);
  fill(0,0,0);
  text("Keyframes Added: " + keyFrames.size(),20,160);
  camera.endHUD();
  hint(ENABLE_DEPTH_TEST);
}

void setupGUI() {
  cp5 = new ControlP5(this);
  // add a horizontal sliders, the value of this slider will be linked
  // to variable 'mouseInfluenceSize' 
  cp5.addSlider("interactionRadius")
     .setPosition(20,20)
     .setRange(0,50)
     .setColorCaptionLabel(0)
     ;
  cp5.addSlider("mouseInfluenceScalar")
     .setPosition(20,40)
     .setRange(0,1)
     .setColorCaptionLabel(0)
     ;
  cp5.addSlider("stiffnesses")
     .setPosition(20,60)
     .setRange(0,2)
     .setColorCaptionLabel(0)
     ;
  cp5.addSlider("damp")
     .setPosition(20,80)
     .setRange(0,1)
     .setColorCaptionLabel(0)
     ;
  cp5.addSlider("animationRate")
     .setPosition(20,100)
     .setRange(0,1)
     .setColorCaptionLabel(0)
     ;
  cp5.addSlider("moveVelocity")
     .setPosition(20,120)
     .setRange(0,0.5)
     .setColorCaptionLabel(0)
     ;
  cp5.addSlider("gravityScale")
     .setPosition(20,140)
     .setRange(0,2)
     .setColorCaptionLabel(0)
     ;
  cp5.addToggle("loopAnimation")
     .setPosition(20,210)
     .setSize(20,20)
     .setColorCaptionLabel(0)
     ;
  cp5.addToggle("showPins")
     .setPosition(20,170)
     .setSize(20,20)
     .setColorCaptionLabel(0)
     ;
  cp5.addToggle("showMesh")
     .setPosition(80,170)
     .setSize(20,20)
     .setColorCaptionLabel(0)
     ;
  cp5.addSlider("theta")
     .setPosition(20,250)
     .setRange(0,360)
     .setColorCaptionLabel(0)
     ;
  cp5.setAutoDraw(false);
}

void drawAxes(float size){
  //X  - red
  stroke(192,0,0);
  line(0,0,0,size,0,0);
  //Y - green
  stroke(0,192,0);
  line(0,0,0,0,size,0);
  //Z - blue
  stroke(0,0,192);
  line(0,0,0,0,0,size);
}