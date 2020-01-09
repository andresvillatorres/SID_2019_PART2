int filterWeight = 16;
int numReadings = 8;
float average = 0;
float realTimeRead = 0;

void filtering(){
	lowPassShortSamples(0.75,sigmaSignal);
	realTimeRead = valF[3];
	float size = 0.5;
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