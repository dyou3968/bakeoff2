import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window, set later
int trialCount = 5; //WILL BE MODIFIED FOR THE BAKEOFF
 //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 1.0f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done

int option = 0;

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 500;
float logoY = 500;
float logoZ = 50f;
float logoRotation = 0;

boolean canSubmit = false;

float curX = 0;
float curY = 0;

private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

void setup() {
  
  size(1000, 800);  
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards
  
  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  println("creating "+trialCount + " targets");
  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(border, width-border); //set a random x with some padding
    d.y = random(border, height-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}



void draw() {

  background(40); //background is dark grey
  fill(200);
  noStroke();

  
  //Test square in the top left corner. Should be 1 x 1 inch
  //rect(inchToPix(0.5), inchToPix(0.5), inchToPix(1), inchToPix(1));

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  
  
  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    
    rotate(radians(d.rotation)); //rotate around the origin of the Ddestination trial
    noFill();
    strokeWeight(3f);
    if (trialIndex==i)
      stroke(255, 0, 0, 192); //set color to semi translucent
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }

  Destination d = destinations.get(trialIndex);  
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, degrees(logoRotation))<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"   

  //===========DRAW LINE=================
  if (option == 0) {
    stroke(200);
    line(logoX, logoY, d.x, d.y);
  }
  
  
  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  translate(logoX, logoY); //translate draw center to the center oft he logo square
  rotate(logoRotation); //rotate using the logo square as the origin
  noStroke();


   if (closeDist & closeRotation & closeZ) {
    fill(#34B233);
    cursor(HAND);
    canSubmit = true;
  } else {
    fill(60, 60, 192, 192);
    cursor(ARROW);
  }  

  rect(0, 0, logoZ, logoZ);
  popMatrix();

  //===========DRAW EXAMPLE CONTROLS=================
  
  scaffoldControlLogic();
  fill(255);
  text("Trial " + (trialIndex+1) + " of " +trialCount, inchToPix(1f), inchToPix(.3f));
}



//my example design for control, which is terrible
void scaffoldControlLogic()
{
  
  Destination d = destinations.get(trialIndex);  
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, degrees(logoRotation))<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"    
  
  noStroke();
  if (option == 0) {
    stroke(#90EE90);
    strokeWeight(6);
  }
  if (closeDist) {
    fill(#34B233);
  } else {
    fill(255);
  }
  rect(width/4, inchToPix(.6f), 80, 60);
  fill(0);
  text("Move", width/4, inchToPix(.7f));
  
  noStroke();
  if (option == 1) {
    stroke(#90EE90);
    strokeWeight(6);
  }  
  if (closeRotation) {
    fill(#34B233);
  } else {
    fill(255);
  } 
  rect(width/2, inchToPix(.6f), 80, 60);
  fill(0);
  text("Rotate", width/2, inchToPix(.7f));
  
  if (closeZ) {
    fill(#34B233);
  } else {
    fill(255);
  }   
  noStroke();
  if (option == 2) {
    stroke(#90EE90);
    strokeWeight(6);
  }    
  rect(width*3/4, inchToPix(.6f), 80, 60);
  fill(0);
  text("Resize", width*3/4, inchToPix(.7f));  
}

void mousePressed()
{
  
  if (canSubmit) {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
      return;
    }
    canSubmit = false;
    option = 0;
    return;
  }   
  
  if (dist(width/4, inchToPix(.6f), mouseX, mouseY)< inchToPix(.6f)){
    option = 0;
    return;
  } else if (dist(width/2, inchToPix(.6f), mouseX, mouseY)< inchToPix(.6f)){
    option = 1;
    return;
  } else if (dist(width*3/4, inchToPix(.6f), mouseX, mouseY)< inchToPix(.6f)){
    option = 2;
    return;
  }   

  if (option == 0) {
    logoX = mouseX;
    logoY = mouseY;
  } else if (option == 1) {  
    logoRotation = (float) (atan2(mouseY - logoY, mouseX - logoX) + PI/4);
  } else {
    logoZ = 1.5*dist(mouseX, mouseY, logoX, logoY);
  }    
  
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
}

//void mouseWheel(MouseEvent event) {
//  float e = event.getCount();
//  option = int((option + abs(e)) % 3);
//  println(e);
//  println("test");
//}

void mouseReleased()
{
  Destination d = destinations.get(min(trialIndex, trialCount - 1));  
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, degrees(logoRotation))<=5;
  //boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"    
  
  if (closeDist & closeRotation) {
    option = 2;
  } else if (closeDist) {
    option = 1;
  } else {
    option = 0;
  }
  

}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);  
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, degrees(logoRotation))<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"  

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}
