float [] sigmaSignal = new float[12];
float [] xSigmaMagneto = new float[12];
float [] ySigmaMagneto = new float[12];
float [] zSigmaMagneto = new float[12];

void initializeSigmaSignal(){
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


void updateMagnetometerSamples(float vX,float vY, float vZ){
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

float aftAvMagX=0.0;
float aftAvMagY=0.0;
float aftAvMagZ=0.0;
void afterFilterMagSignals(){
  float thisAverageX=0.0;
  float thisAverageY=0.0;
  float thisAverageZ=0.0;
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




float afterAvCapS=0.0;
void afterFilterSignal(){
  float thisAverage=0.0;
  for (int i=0; i< sigmaSignal.length; i++)
  {
    thisAverage = thisAverage+ sigmaSignal[i];
  }
  afterAvCapS = thisAverage/sigmaSignal.length;
}

void updateShortSamples(float v) {
  for (int i= 0; i < sigmaSignal.length-1; i ++)
  {
    sigmaSignal[i]=sigmaSignal[i+1];
  }
  sigmaSignal[sigmaSignal.length-1]=(v);
}


void lowPassShortSamples(float k, float[] data)
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


void plotSignal(){
  noFill();
  stroke(80, 140, 255);
  strokeWeight(2);
  beginShape(); 
  for (int i=0; i < sigmaSignal.length; i++) {
    vertex( 1 * map(i,0,sigmaSignal.length-1,0,width), height - map(sigmaSignal[i],0,512,0,500));
  }
  endShape();
}

void lowPass(float k, float[] data)
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
void highPass(float a, float[] data)
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
float dynamicMinMaxNorth(float value){
  float vOut;
  float direction = prevVN - value ;
  float thisThreshold =0.75;
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
float dynamicMinMaxCS(float value){
  float vOut;
  float direction = prevVCS - value ;
  float thisThreshold =0.15;
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
  vOut = constrain(vOut,0,3.0);
  return vOut;
}
