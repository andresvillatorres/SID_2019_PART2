
import oscP5.*;
import netP5.*;

import java.awt.MouseInfo;
import java.awt.Point;


OscP5 oscP5;
NetAddress myRemoteLocation;

float compasRotation=0.0;
float lastCompasRotation=0.0;
float addRotation=0.0;
float pitch = 0.0;
float roll  = 0.0;
float yaw   = 0.0;

float magx  = 0.0;

float maxPitch=1.0;
float smooth_compasRotation=0.0;
float smooth_pitch=0.0;
float smooth_roll=0.0;

void setup() {
  size(800,800,P3D);
  frameRate(60);
  smooth(8);
  pixelDensity(2);

  directionalLight(126, 126, 126, 0, 0, -1);
  ambientLight(102, 102, 202);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);

  myRemoteLocation = new NetAddress("127.0.0.1", 57120);  //  speak to

}
float vX=0.0;
int direction=0;
void draw() {
  background(255);  
  directionalLight(255, 0, 150, 1, 0.5, -1);
  directionalLight(0, 0, 255, -1, -0.5, -1);
  noStroke();
  smooth_compasRotation= addRotation*0.15 + smooth_compasRotation*0.85;

  if(compasRotation > lastCompasRotation && abs(lastCompasRotation-compasRotation)<180.0){
    direction= 1;
  }
  if(compasRotation < lastCompasRotation && abs(lastCompasRotation-compasRotation)<180.0){
    direction= -1;
  }


  if(compasRotation>lastCompasRotation 
    // && abs(lastCompasRotation-compasRotation)>=0.001 
    && abs(lastCompasRotation-compasRotation)<240.0
   ){
    addRotation-=abs(lastCompasRotation-compasRotation);
  }

  if(compasRotation<lastCompasRotation 
    // && abs(lastCompasRotation-compasRotation)>=0.001 
    && abs(lastCompasRotation-compasRotation)<240.0
   ){
    addRotation+=abs(lastCompasRotation-compasRotation);
  }
  calculateSpeed();
  // for(int much=0;much<200;much++){
  pushMatrix();
    translate(width/2,height/2+magx/2,-100);
      pushMatrix();
        rotateY(radians(smooth_compasRotation));
        if(pitch>maxPitch){
          maxPitch=pitch;
        }
        float thisPitch =  map (pitch,0,maxPitch,0,90);
        smooth_pitch = smooth_pitch*0.85 + thisPitch*0.15;

        rotateX(radians(smooth_pitch));
        fill(255);
        box(250,250- (magx),250);
      popMatrix();
  popMatrix();
  // }

  fill(150);
  textSize(14);
  text(pitch,width/2,25);
  text(roll,width/2,40);
  text(yaw,width/2,55);
  text(" real rotation : " + compasRotation,width/2,70);
  text(" added rotation : " + smooth_compasRotation,width/2,85);
  text(" direction : " + direction,width/2,100);
  text(" speed : " + speed , width/2, 115);
  text(" mag x : " + magx, width/2, 130);
  // text(pitch + " , "  + roll + " , " + yaw + " , " + ,width/2,25);
  Point custoMouse;
  custoMouse = MouseInfo.getPointerInfo().getLocation();
  // println( "X=" + mouse.x + " Y=" + mouse.y );
  vX=custoMouse.x*0.15 + vX*0.85;
  // if(mousePressed){
      theSoundMessage2(map(vX,0,1400,-150,150));
  // }
  lastCompasRotation=compasRotation;
}


void rotDirection(){

}
void mousePressed(){

}
void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/gyro")==true){
    //pitch == 0 , roll == 1 , yaw == 2
    pitch=theOscMessage.get(0).floatValue();
    roll = theOscMessage.get(1).floatValue();
    yaw = theOscMessage.get(2).floatValue();
  }
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/comp")==true){
    // println();
    compasRotation=theOscMessage.get(0).floatValue();
    // println(,theOscMessage.get(1).floatValue(),theOscMessage.get(2).floatValue());
  }
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/gps")==true){
    // println(theOscMessage.get(0).floatValue(),theOscMessage.get(1).floatValue(),theOscMessage.get(2).floatValue(),theOscMessage.get(3).floatValue(),theOscMessage.get(4).floatValue(),theOscMessage.get(5).floatValue() );
  }
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/mag")==true){
    // println(theOscMessage.get(0).floatValue(),theOscMessage.get(1).floatValue(),theOscMessage.get(2).floatValue());
    magx=theOscMessage.get(0).floatValue();
  }
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/alt")==true){
    // println(theOscMessage.get(0).floatValue());
  }
}

void theSoundMessage(float _value){
  OscMessage newMessage = new OscMessage("/sound");  
  newMessage.add(_value); 
  oscP5.send(newMessage, myRemoteLocation);
}
void theSoundMessage2(float _value){
  OscMessage newMessage = new OscMessage("/sound2");  
  newMessage.add(_value); 
  oscP5.send(newMessage, myRemoteLocation);
}

float prRot=0.0;
float speed=0.0;
float _lSpeed=0.0;
void calculateSpeed(){
  speed  = (smooth_compasRotation - prRot);
  if(smooth_compasRotation!=prRot){
      theSoundMessage(abs(speed));
  }
  prRot=smooth_compasRotation;
  _lSpeed=speed;
}
