
/*
  Processing example to connect via Client to 
  an arduino mk1000 sending Sensor Data (HMC5883L)
  
  ADAFRUIT LIBRARY repo
  https://github.com/pkourany/Adafruit_HMC5883_U/blob/master/Adafruit_Sensor.h

  Written for Sonic Interaction Design HS2019 - Mapping Gestures
  Interaction Design
  ZHdK
  ************************
  ************************
  ************************

  November - Januar 2019/20
  By ndr3s -v -t (Andrés Villa Torres)
*/
import processing.net.*;  
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;
NetAddress myRemoteLocationSC;// supercollider

Client myClient; 
String dataIn="";
byte [] byteBuffer = new byte[64];
byte interesting = byte('!');
float [] valF;
ActiveBox [] faces = new ActiveBox[6] ;
boolean clientConnected = false;

void setup() { 
  size(600, 640,FX2D); 
  frameRate(120);
  // Connect to the local machine at port 5204.
  // This example will not run if you haven't
  // previously started a server on this port.
  myClient = new Client(this, "192.168.1.31", 80);
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 11000); // REaper
  myRemoteLocationSC = new NetAddress("127.0.0.1", 57120); // SuperCollider

  // 192.168.1.70
  // 192.168.1.195
  // 192.168.1.229
  // 192.168.1.41 
  // 192.168.1.137

  if(!clientConnected){
        clientConnected=true;
      }
   valF = new float[5];
   for (int i = 0; i < valF.length;i++){
    valF[i]=0.0;
   }
  initializeSigmaSignal();

/* 
  0 = upright
  1 = upsidedown
  2 = front
  3 = right
  4 = back
  5 = left
*/  
  float tX =400;
  float tY= 100;
  float tS = 50;
  faces[0] = new ActiveBox(tX, tY,tS);
  faces[1] = new ActiveBox(tX, tY+120,tS);
  faces[2] = new ActiveBox(tX, tY-60,tS);
  faces[3] = new ActiveBox(tX+60, tY,tS);
  faces[4] = new ActiveBox(tX, tY+60,tS);
  faces[5] = new ActiveBox(tX-60, tY,tS);
} 


void draw() { 
    background(255);
    fill(0);
    noStroke();
    rect(0,0,width,height/2);

    fill(255);
    textSize(12);
    text("in values at " + nf(frameRate,0,2) + " fps", 50, 25);

    readClient();
    displayFilteredValues();
    plotSignal();
    magnetoMeterShakyness();

    faceOrientation();
    // continuousNote();
    noteOnTouch();
    // noteOnTouchContinuous();

} 

String values="";
void readClient(){

    if(clientConnected){
      if (myClient.available()>0) { 

        // Read until we get a linefeed
        int byteCount = myClient.readBytesUntil(interesting, byteBuffer); 
        // Convert the byte array to a String
        String myString = new String(byteBuffer);
        values = trim(myString);
        // Display the string

        String[] list = split(values, ',');
        // valF = new float[list.length];
        // float [] valu
        if(list.length>0){
          for(int i=0; i < list.length;i ++){
            list[i]=list[i].replaceAll("!","");
            if(list.length==4){
            valF[0]=float(list[0]); // magnetometer.x
            valF[1]=float(list[1]); // magnetometer.y
            valF[2]=float(list[2]); // magnetometer.z
            valF[3]=float(list[3]); // cap sensing value
            // valF[4]=float(list[4]); ... and so on
            }
          }
        }     
      } 
    }
}



void displayFilteredValues(){
    filtering();
    strokeWeight(2);
    noFill();
    float size = 0.5;
    stroke(100,100,255);
    fill(0,255,0);
    text("mag X : " + aftAvMagX,50,60 + 24*0);
    fill(255,255,0);
    text("mag Y : " + aftAvMagY, 50, 60 +24*1);
    fill(0,255,255);
    text("mag Z : " + aftAvMagZ, 50, 60 +24*2);
    fill(100,100,255);
    text("Capacitive Sensor : " + afterAvCapS ,50,60 + 24*3);
    north();


}



float pNorth=0;
float lastNorth=0;
float northShakyness =0;
float time =0;  
float headingDegrees=0;
void north(){
     float heading = atan2(aftAvMagY, aftAvMagX);
      float declinationAngle = 0.22;
      heading += declinationAngle;
      if (heading < 0)
        heading += 2 * PI;
      if (heading > 2 * PI)
        heading -= 2 * PI;
      headingDegrees = heading * 180 / PI;
      pNorth = pNorth*0.9 + headingDegrees*0.1;
      
      fill(100,100,255);
      text("north : " + headingDegrees,50,60 + 24*4);
      
      pushMatrix();
      translate(425,height/2 + 50);
      rotate(radians(headingDegrees));
      stroke(100,100,255);
      strokeWeight(4);
      fill(255,0,0);
      ellipse(0,0,50,50);
      line(0,0,25,0);
      text(nf(headingDegrees,0,2),35,0);
      popMatrix();
      orientationShakyness();
}

void orientationShakyness(){
  northShakyness = abs(lastNorth-headingDegrees )/ abs(time - millis());
  text("orientation shakyness : " + nf(northShakyness,0,2), 50,60 + 24*6) ;
  lastNorth = headingDegrees;
  time = millis();
}

float time2=0;
float allMagValues=0;
float lastMagValues=0;
float magShakyness=0;
void magnetoMeterShakyness(){
  allMagValues = aftAvMagX + aftAvMagY +aftAvMagZ ;
  // println(allMagValues);
  magShakyness = abs(lastMagValues - allMagValues)/abs(time2-millis());
  text("magnetometer Shakyness : " + nf(magShakyness,0,4), 50, 60 + 24*7);
  lastMagValues = allMagValues;
  time2 = millis();
}


/* 
  0 = upright
  1 = upsidedown
  2 = front
  3 = right
  4 = back
  5 = left
*/ 

// example to trigger a Sound via faceOrientation manually setting
// each certain variation depending on the signals readed by the magnetometer

int faceOnGround= 0; 
String faceLabel="";
String lastFaceLabel = ""; 
void faceOrientation(){

  if(aftAvMagX<50  &&(aftAvMagY<-5 && aftAvMagY>-35) &&  aftAvMagZ<0){
    faceOnGround = 0;
    faceLabel= "upright";
    
  }
  if((aftAvMagZ>30 && aftAvMagX<0) || ( aftAvMagX >40 && (aftAvMagY>-15 && aftAvMagY<15) &&aftAvMagZ >70)){
    faceOnGround = 1;
    faceLabel = "upsidedown";
  }
  if(aftAvMagZ>0 && aftAvMagX>50){
    faceOnGround = 2;
    faceLabel = "front";
  }
  if(aftAvMagX<50  &&(aftAvMagY<-50 && aftAvMagY>-85) &&  aftAvMagZ<0){
    faceOnGround = 3;
    faceLabel= "right";
  }
  if(aftAvMagX<0  &&(aftAvMagY<0) &&  aftAvMagZ<0){
    faceOnGround = 4;
    faceLabel= "back";
  }
  if(aftAvMagX>40  &&(aftAvMagY>30) &&  aftAvMagZ<-20){
    faceOnGround = 5;
    faceLabel= "left";
  }

  if(!lastFaceLabel.equals(faceLabel)){
    // the "+ 15 " is to shift the midi note up 15 keys
    noteON(faceOnGround+25, 1);
  }
  for(int i = 0; i < faces.length; i ++){
    if( faceOnGround == i){
      faces[i].display(true);
    }else{
      faces[i].display(false);
    }
  }
  fill(255,0,0);
  text(faceLabel,400,height/2 -25);
  lastFaceLabel=faceLabel;
}

// example to trigger a Sound via noteON each certain variation of a continuous signal
float lastMagX=0;
void continuousNote(){
  int  deltaMagX = int(abs(lastMagX - valF[0]));
  if(deltaMagX>1){
    noteON(10+deltaMagX,2);  
  }else{
  }
  
  lastMagX = valF[0];
}

// example to trigger a Sound via touch on OFF
boolean touchFlag=false;
float capSThreshold = 70.0;
void noteOnTouch(){
  if(afterAvCapS > (capSThreshold) && !touchFlag){
    touchFlag=true;
    println("touched");
    noteON(48,1);
    noteON_SC(afterAvCapS);
  }else{
    if((afterAvCapS < (capSThreshold-30) && touchFlag)){
      touchFlag=false;
      println("un touched");
    }
  }

}

// example to trigger a Sound via touch continuous
float lastCapS=0;
void noteOnTouchContinuous(){
  float deltaCapS = abs(lastCapS-afterAvCapS);
  // println(deltaCapS);
  if( deltaCapS > 2){
      // println("touched");
    noteON(48,1);
    noteON_SC(afterAvCapS);
  }
  // if(afterAvCapS > (capSThreshold) && !touchFlag){
  //   touchFlag=true;
  //   println("touched");
  //   noteON(48,1);
  // }else{
  //   if((afterAvCapS < (capSThreshold-50) && touchFlag)){
  //     touchFlag=false;
  //     println("un touched");
  //   }
  // }

  lastCapS = afterAvCapS;
}

class ActiveBox{
  float bx =400;
  float by= 100;
  float bs = 50;
  ActiveBox(float _x , float _y, float _bs){
      bx = _x;
      by = _y;
      bs = _bs;
  }

  void display(boolean onOff){
    if(onOff){
      fill(255,0,0);
      stroke(100,100,255);
      strokeWeight(4);
      rect(bx,by,bs,bs);
    }else{
      fill(255,2000,200);
      stroke(100,100,255);
      strokeWeight(2);
      rect(bx,by,bs,bs);
    }
  }
}