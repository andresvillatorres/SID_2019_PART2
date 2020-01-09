
float compasRotation=0.0;
float lastCompasRotation=0.0;
float addRotation=0.0;
float pitch = 0.0;
float roll  = 0.0;
float yaw   = 0.0;
float magx  = 0.0;
float smooth_compasRotation=0.0;
float smooth_pitch=0.0;
float smooth_roll=0.0;
float smooth_yaw=0.0;
float smooth_magx=0.0;
void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/gyro")==true){
    //pitch == 0 , roll == 1 , yaw == 2
    pitch=theOscMessage.get(0).floatValue();
    // println("picth : " + pitch);
    roll = theOscMessage.get(1).floatValue();
    yaw = theOscMessage.get(2).floatValue();
  }
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/comp")==true){
    // println();

    compasRotation=theOscMessage.get(0).floatValue();
      // println(compasRotation);
    // println(,theOscMessage.get(1).floatValue(),theOscMessage.get(2).floatValue());
  }
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/gps")==true){
    // println(theOscMessage.get(0).floatValue(),theOscMessage.get(1).floatValue(),theOscMessage.get(2).floatValue(),theOscMessage.get(3).floatValue(),theOscMessage.get(4).floatValue(),theOscMessage.get(5).floatValue() );
  }
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/mag")==true){
    // println(theOscMessage.get(0).floatValue(),theOscMessage.get(1).floatValue(),theOscMessage.get(2).floatValue());
    // magx=theOscMessage.get(0).floatValue();
  }
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/alt")==true){
    // println(theOscMessage.get(0).floatValue());
  }
}
