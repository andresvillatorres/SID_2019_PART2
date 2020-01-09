import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.net.*; 
import oscP5.*; 
import netP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class wifi_client_Magneto_Capacitive extends PApplet {


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
  


OscP5 oscP5;
NetAddress myRemoteLocation;
NetAddress myRemoteLocationSC;// supercollider

Client myClient; 
String dataIn="";
byte [] byteBuffer = new byte[64];
byte interesting = PApplet.parseByte('!');
float [] valF;
ActiveBox [] faces = new ActiveBox[6] ;
boolean clientConnected = false;

public void setup() { 
   
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
    valF[i]=0.0f;
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


public void draw() { 
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
public void readClient(){

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
            valF[0]=PApplet.parseFloat(list[0]); // magnetometer.x
            valF[1]=PApplet.parseFloat(list[1]); // magnetometer.y
            valF[2]=PApplet.parseFloat(list[2]); // magnetometer.z
            valF[3]=PApplet.parseFloat(list[3]); // cap sensing value
            // valF[4]=float(list[4]); ... and so on
            }
          }
        }     
      } 
    }
}



public void displayFilteredValues(){
    filtering();
    strokeWeight(2);
    noFill();
    float size = 0.5f;
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
public void north(){
     float heading = atan2(aftAvMagY, aftAvMagX);
      float declinationAngle = 0.22f;
      heading += declinationAngle;
      if (heading < 0)
        heading += 2 * PI;
      if (heading > 2 * PI)
        heading -= 2 * PI;
      headingDegrees = heading * 180 / PI;
      pNorth = pNorth*0.9f + headingDegrees*0.1f;
      
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

public void orientationShakyness(){
  northShakyness = abs(lastNorth-headingDegrees )/ abs(time - millis());
  text("orientation shakyness : " + nf(northShakyness,0,2), 50,60 + 24*6) ;
  lastNorth = headingDegrees;
  time = millis();
}

float time2=0;
float allMagValues=0;
float lastMagValues=0;
float magShakyness=0;
public void magnetoMeterShakyness(){
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
public void faceOrientation(){

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
public void continuousNote(){
  int  deltaMagX = PApplet.parseInt(abs(lastMagX - valF[0]));
  if(deltaMagX>1){
    noteON(10+deltaMagX,2);  
  }else{
  }
  
  lastMagX = valF[0];
}

// example to trigger a Sound via touch on OFF
boolean touchFlag=false;
float capSThreshold = 70.0f;
public void noteOnTouch(){
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
public void noteOnTouchContinuous(){
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

  public void display(boolean onOff){
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
int filterWeight = 16;
int numReadings = 8;
float average = 0;
float realTimeRead = 0;

public void filtering(){
	lowPassShortSamples(0.75f,sigmaSignal);
	realTimeRead = valF[3];
	float size = 0.5f;
	for (int i = 0; i < numReadings ; i ++){
		average=average + (realTimeRead -average)/filterWeight;
	}
	noFill();
	stroke(255,0,0);
	strokeWeight(2);
    fill(255,0,0);
	noFill();
	stroke(255,0,0);
	strokeWeight(2);
	updateShortSamples(average);
	afterFilterSignal();
	updateMagnetometerSamples(valF[0], valF[1], valF[2]);
}

// boolean touchFlag=false;
// float touchThreshold=100.0;
// void touchEvent(){
// 	if(average>touchThreshold+0.5 && !touchFlag){
// 		touchFlag=true;
// 		println("touch threshold crossed");
// 	}else{
// 		if(average<touchThreshold+0.5 && touchFlag){
// 			touchFlag=false;
// 			println("touch threshold left");
// 		}
// 	}
// 	if(touchFlag){
// 		fill(255,100,0);
// 		noStroke();
// 	}else{
// 		noFill();
// 		stroke(200,200,200);
// 		strokeWeight(4);
// 	}
// }
float [] sigmaSignal = new float[12];
float [] xSigmaMagneto = new float[12];
float [] ySigmaMagneto = new float[12];
float [] zSigmaMagneto = new float[12];

public void initializeSigmaSignal(){
  for (int i=0; i< sigmaSignal.length; i++)
  {
    sigmaSignal[i]=0;
  }
    for (int i=0; i< xSigmaMagneto.length; i++)
  {
    xSigmaMagneto[i]=0;
    ySigmaMagneto[i]=0;
    zSigmaMagneto[i]=0;
  }
}


public void updateMagnetometerSamples(float vX,float vY, float vZ){
  for (int i= 0; i < xSigmaMagneto.length-1; i ++)
  {
    xSigmaMagneto[i]=xSigmaMagneto[i+1];
    ySigmaMagneto[i]=ySigmaMagneto[i+1];
    zSigmaMagneto[i]=zSigmaMagneto[i+1];
  }
  xSigmaMagneto[xSigmaMagneto.length-1]=(vX);
  ySigmaMagneto[ySigmaMagneto.length-1]=(vY);
  zSigmaMagneto[zSigmaMagneto.length-1]=(vZ);
  afterFilterMagSignals();
}

float aftAvMagX=0.0f;
float aftAvMagY=0.0f;
float aftAvMagZ=0.0f;
public void afterFilterMagSignals(){
  float thisAverageX=0.0f;
  float thisAverageY=0.0f;
  float thisAverageZ=0.0f;
  for (int i=0; i< xSigmaMagneto.length; i++)
  {
    thisAverageX = thisAverageX+ xSigmaMagneto[i];
    thisAverageY = thisAverageY + ySigmaMagneto[i];
    thisAverageZ = thisAverageZ + zSigmaMagneto[i];
  }
  aftAvMagX = thisAverageX/xSigmaMagneto.length;
  aftAvMagY = thisAverageY/ySigmaMagneto.length;
  aftAvMagZ = thisAverageZ/zSigmaMagneto.length;
}




float afterAvCapS=0.0f;
public void afterFilterSignal(){
  float thisAverage=0.0f;
  for (int i=0; i< sigmaSignal.length; i++)
  {
    thisAverage = thisAverage+ sigmaSignal[i];
  }
  afterAvCapS = thisAverage/sigmaSignal.length;
}

public void updateShortSamples(float v) {
  for (int i= 0; i < sigmaSignal.length-1; i ++)
  {
    sigmaSignal[i]=sigmaSignal[i+1];
  }
  sigmaSignal[sigmaSignal.length-1]=(v);
}


public void lowPassShortSamples(float k, float[] data)
{
  if (data.length<2 )
    return;
  float prevSignal = data[0];
  for (int i=0; i < data.length; i++)
  {
    data[i] = prevSignal + k * (data[i] - prevSignal); 
    prevSignal = data[i];
  }
}  


public void plotSignal(){
  noFill();
  stroke(80, 140, 255);
  strokeWeight(2);
  beginShape(); 
  for (int i=0; i < sigmaSignal.length; i++) {
    vertex( 1 * map(i,0,sigmaSignal.length-1,0,width), height - map(sigmaSignal[i],0,512,0,500));
  }
  endShape();
}

public void lowPass(float k, float[] data)
{
  if (data.length<2 )
    return;
  float prevSignal = data[0];
  for (int i=0; i < data.length; i++)
  {
    data[i] = prevSignal + k * (data[i] - prevSignal); 
    prevSignal = data[i];
  }
}   



// filters all high freq. out
public void highPass(float a, float[] data)
{
  if (data.length < 2)
    return;

  float prevSignal = data[0];

  for (int i=0; i < data.length; i++)
  {
    prevSignal = prevSignal + a * (data[i] - prevSignal); 
    data[i] = prevSignal - data[i];
  }
}  

float vMinN;
float vMaxN;
float prevVN;
boolean upDownN=false;
public float dynamicMinMaxNorth(float value){
  float vOut;
  float direction = prevVN - value ;
  float thisThreshold =0.75f;
  if( abs(direction)> thisThreshold && direction < 0 && !upDownN){
    vMinN = prevVN;
    upDownN =true;
  } else{
    if(upDownN && abs(direction)> thisThreshold && direction < 0){
    } 

    if(abs(direction)> thisThreshold && direction > 0 && upDownN){
        upDownN=false;
        vMaxN = value;
    }else{
      if(abs(direction)> thisThreshold && direction > 0 && !upDownN){
      }
    }
  }
  prevVN = value;
  vOut =(value-vMinN)/(vMaxN-vMinN);
  return vOut;
}


float vMinCS;
float vMaxCS;
float prevVCS;
boolean upDownCS=false;
public float dynamicMinMaxCS(float value){
  float vOut;
  float direction = prevVCS - value ;
  float thisThreshold =0.15f;
  if( abs(direction)> thisThreshold && direction < 0 && !upDownCS){
    vMinCS = prevVCS;
    upDownCS =true;
  } else{
    if(upDownCS && abs(direction)> thisThreshold && direction < 0){
    } 

    if(abs(direction)> thisThreshold && direction > 0 && upDownCS){
        upDownCS=false;
        vMaxCS = value;
    }else{
      if(abs(direction)> thisThreshold && direction > 0 && !upDownCS){
      }
    }
  }
  prevVCS = value;
  vOut =(value-vMinCS)/(vMaxCS-vMinCS);
  vOut = constrain(vOut,0,3.0f);
  return vOut;
}
public void noteON(int _note, int _channel){
	// custom midi channel via variable "channel"
	// > be aware that in reaper the midi channels are shifted by 1
	// i. e. if you send channel 0 it will be 1 in reaper, 1 will be 2 in reaper and so on
    OscMessage myMessage = new OscMessage("i/vkb_midi/"+_channel+"/note/"+_note);
    myMessage.add(50.0f); 
    oscP5.send(myMessage, myRemoteLocation);
}

public void noteOFF(int _note){
	// fixed midi channel 0
    OscMessage myMessage = new OscMessage("i/vkb_midi/0/note/"+_note);
    myMessage.add(0); 
    oscP5.send(myMessage, myRemoteLocation);
}

public void noteON_SC(float _value){
  OscMessage newMessage = new OscMessage("/sound");  
  newMessage.add(_value); 
  oscP5.send(newMessage, myRemoteLocationSC);
}
  public void settings() {  size(600, 640,FX2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--stop-color=#cccccc", "wifi_client_Magneto_Capacitive" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
