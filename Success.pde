import ddf.minim.*;
import processing.serial.*;

int lf = 10;
String myString = null;
int backgroundColor = 244;
int snakeLength = 12;  
int snakeLength2 = 12;   //Initial length of snake
int snakeHeadX;         //head(x,y)
int snakeHeadY;
int snakeHeadX2;         //head(x,y)
int snakeHeadY2;
char snakeDirection = 'R';  //UP/DOWN/LEFT/RIGHT
char snakeDirection2 = 'U';
char snakeDirectionTemp;
char snakeDirectionTemp2;
float[] sensorValue = new float[4];

int w=30;   //SnakeHead's Food's and oneStep's length(pix)

int maxSnakeLength = 1000;
int[] x = new int [maxSnakeLength];
int[] y = new int [maxSnakeLength];
int[] x2 = new int [maxSnakeLength];
int[] y2 = new int [maxSnakeLength];

//int bestScore = snakeLength;
boolean gameOverKey = false;
////////
int EatCount = 1;

boolean foodKey = true;
int foodX;
int foodY;

boolean item1Key = true;
int item1X;
int item1Y;

boolean item2Key = true;
int item2X;
int item2Y;
//////////
int mode = 0;

int savedTime; 
int totalTime;
int passedTime;

boolean isOneWin = false;
boolean isTwoWin = false;

PImage img;
PImage OneWin;
PImage TwoWin;
PImage F1;
PImage F2;
PImage F3;
PImage B1;
PImage B2;

Minim minim1;
Minim minimbgm;
Minim minimwin;
Minim minimeat;
AudioPlayer player1;
AudioPlayer playerbgm;
AudioPlayer playerwin;
AudioPlayer playereat;
Serial myPort;

void setup(){
    size(900,900);
    frameRate(30);
    noStroke();
    myPort = new Serial(this,"COM3", 9600);  
    myPort.bufferUntil('\n');
    
    savedTime = millis(); 
    img = loadImage("bg.jpg");
    OneWin = loadImage("Purple.jpg");
    TwoWin = loadImage("Yellow.jpg");
    F1 = loadImage("1.png");
    F2 = loadImage("2.png");
    F3 = loadImage("3.png");
    B1 = loadImage("bonus1.jpg");
    B2 = loadImage("bonus2.jpg");
    minim1 = new Minim(this);
    player1 = minim1.loadFile("Coll.mp3");
    minimbgm = new Minim(this);
    playerbgm = minimbgm.loadFile("bgm.mp3");
    minimwin = new Minim(this);
    playerwin = minimwin.loadFile("win.mp3");
    minimeat = new Minim(this);
    playereat = minimeat.loadFile("Eat.mp3");
}

int speed = 4;  //范围1~20比较好些，每秒移动的步数

void draw(){
    totalTime = 1000/speed; 
    passedTime = millis()- savedTime;
    if(mode == 2){
        streched();
    }
    else{
        streched2();
        }
    if (passedTime > totalTime ) {
        if(isGameOver() ){
            speed = 4;  //set the orogin speed
            return;
        }
        
        image(img,0,0,900,900);

        switch(snakeDirection){
            case 'L':
                snakeHeadX -= w;
                break;
            case 'R':
                snakeHeadX += w;
                break;
            case 'D':
                snakeHeadY += w;
                break;
            case 'U':
                snakeHeadY -= w;
                break;
        }
        
       switch(snakeDirection2){
            case 'L':
                snakeHeadX2 -= w;
                break;
            case 'R':
                snakeHeadX2 += w;
                break;
            case 'D':
                snakeHeadY2 += w;
                break;
            case 'U':
                snakeHeadY2 -= w;
                break;
        }
//add another food
        if(EatCount % 2 != 0 && EatCount % 3 != 0){
            drawFood(width,height);
        }
        else if(EatCount % 2 == 0){
            drawItem1(width,height);
        }
        else if(EatCount % 3 == 0){
            drawItem2(width,height);
        }
        
        if( snakeHeadX == foodX && snakeHeadY == foodY){
            playereat.rewind();
            EatCount++;
            snakeLength++;
            //set the speed
            speed ++;
            speed = min(20,speed);  //speed's max value is 15
            foodKey = true;
        }
        if( snakeHeadX2 == foodX && snakeHeadY2 == foodY){
            playereat.rewind();
            EatCount++;
            snakeLength2++;
            //set the speed
            speed ++;
            speed = min(20,speed);  //speed's max value is 15
            foodKey = true;
        }
        
        
        if( snakeHeadX == item1X && snakeHeadY == item1Y){
            playereat.rewind();
            EatCount++;
            snakeLength += 2;
            //set the speed
            speed ++;
            speed = min(20,speed);  //speed's max value is 15
            item1Key = true;
        }
        if( snakeHeadX2 == item1X && snakeHeadY2 == item1Y){
            playereat.rewind();
            EatCount++;
            snakeLength2 += 2;
            //set the speed
            speed ++;
            speed = min(20,speed);  //speed's max value is 15
            item1Key = true;
        }
        
        if( snakeHeadX == item2X && snakeHeadY == item2Y){
            playereat.rewind();
            EatCount++;
            snakeLength += 4;
            //set the speed
            speed ++;
            speed = min(20,speed);  //speed's max value is 15
            item2Key = true;
        }
        if( snakeHeadX2 == item2X && snakeHeadY2 == item2Y){
            playereat.rewind();
            EatCount++;
            snakeLength2 += 4;
            //set the speed
            speed ++;
            speed = min(20,speed);  //speed's max value is 15
            item2Key = true;
        }

        //store snake body
        for(int i=snakeLength-1; i>0; i--){
            x[i] = x[i-1];
            y[i] = y[i-1];
        }
        for(int j=snakeLength2-1; j>0; j--){
            x2[j] = x2[j-1];
            y2[j] = y2[j-1];
        }
        //store snake new head
        y[0] = snakeHeadY;
        x[0] = snakeHeadX;
        y2[0] = snakeHeadY2;
        x2[0] = snakeHeadX2;

        stroke(0);  //Black
        strokeWeight(1);    //线宽为1

        //draw snakeHead
        fill(#EE82EE);
        rect(x[0],y[0],w,w);
        
        fill(#FFFACD);
        rect(x2[0],y2[0],w,w);

        //draw snakeBody
        fill(#7B6DB7);
        for(int i=1; i<snakeLength; i++){
            rect(x[i],y[i],w,w);
        }
        fill(#FFD700);
        for(int j=1; j<snakeLength2; j++){
            rect(x2[j],y2[j],w,w);
        }

        if(isSnakeDie()){
            return;
        }

        savedTime = millis(); //passedTime=millis()-savedTime
    }

}//end draw()

void serialEvent(Serial myPort) { 
  try {
    // get the ASCII string:
    String inString = myPort.readStringUntil('\n');
    //println("raw: \t" + inString); // <- uncomment this to debug serial input from Arduino

    if (inString != null) {
     inString = trim(inString);
     sensorValue = float(splitTokens(inString, ", \t"));
      
      
      }
    
  }
  catch(RuntimeException e) {
    // only if there is an error:
    e.printStackTrace();
  }
}

//keyboard interrupt

void streched(){
  if((sensorValue[0] >= 3.5)&&(sensorValue[1] >= 3)){
      snakeDirection = 'D';}
     else if((sensorValue[0] < 3.5)&&(sensorValue[1] < 3)){
       snakeDirection = 'U';}
    else if((sensorValue[0] >= 3.5)&&(sensorValue[1] <3)){
       snakeDirection = 'R';}
     else{
       snakeDirection = 'L';}
       
  if((sensorValue[2] >= 4.5)&&(sensorValue[3] >= 4.2)){
      snakeDirection2 = 'D';}
     else if((sensorValue[2] < 4.5)&&(sensorValue[3] < 4.2)){
       snakeDirection2 = 'U';}
    else if((sensorValue[2] >= 4.5)&&(sensorValue[3] < 4.2)){
       snakeDirection2 = 'R';}
     else{
       snakeDirection2 = 'L';}      
}

void streched2(){
  if((sensorValue[0] >= 3.5)&&(sensorValue[1] >= 3.5)){
      snakeDirection = 'D';}
     else if((sensorValue[0] < 3.5)&&(sensorValue[1] < 3.5)){
       snakeDirection = 'U';}
    else if((sensorValue[0] >= 3.5)&&(sensorValue[1] <3.5)){
       snakeDirection = 'R';}
     else{
       snakeDirection = 'L';}
       
       if(snakeDirection != 'P'){
        switch(key){
            case 'A':
            case 'a':
                if(snakeDirection2 != 'R'){
                snakeDirection2 = 'L';
                break;
                }
                else
                break;
            case 'D':
            case 'd':
                if(snakeDirection2 != 'L'){
                snakeDirection2 = 'R';
                break;
                }
                else
                break;
            case 'S':
            case 's':
                if(snakeDirection2 != 'U'){
                snakeDirection2 = 'D';
                break;
                }
                else
                break;
            case 'W':
            case 'w':
                if(snakeDirection2 != 'D'){
                snakeDirection2 = 'U';
                break;
                }
                else
                break;
        }
    }     
}

//keyboard interrupt
void keyPressed() {
    if(key == CODED){
        switch(keyCode){
            case LEFT:
                if(snakeDirection != 'R'){
                snakeDirection = 'L';
                break;
                }
                else
                break;
            case RIGHT:
                if(snakeDirection != 'L'){
                snakeDirection = 'R';
                break;
                }
                else
                break;
            case DOWN:
                if(snakeDirection != 'U'){
                snakeDirection = 'D';
                break;
                }
                else
                break;
            case UP:
                if(snakeDirection != 'D'){
                snakeDirection = 'U';
                break;
                }
                else
                break;
        }
    }
    if(snakeDirection != 'P'){
        switch(key){
            case 'A':
            case 'a':
                if(snakeDirection2 != 'R'){
                snakeDirection2 = 'L';
                break;
                }
                else
                break;
            case 'D':
            case 'd':
                if(snakeDirection2 != 'L'){
                snakeDirection2 = 'R';
                break;
                }
                else
                break;
            case 'S':
            case 's':
                if(snakeDirection2 != 'U'){
                snakeDirection2 = 'D';
                break;
                }
                else
                break;
            case 'W':
            case 'w':
                if(snakeDirection2 != 'D'){
                snakeDirection2 = 'U';
                break;
                }
                else
                break;
        }
    }
}   //end keyPressed()

void snakeInit(){
    background(backgroundColor);
    x = new int [maxSnakeLength];
    y = new int [maxSnakeLength];
    x2 = new int [maxSnakeLength];
    y2 = new int [maxSnakeLength];
    snakeLength = 12;
    snakeLength2 = 12;
    gameOverKey = false;
    snakeHeadX = 0;
    snakeHeadY = 0;
    snakeHeadX2 = 870;
    snakeHeadY2 = 870;
    snakeDirection = 'R';
    snakeDirection2 = 'U';
    isOneWin = false;
    isTwoWin = false;
    EatCount = 1;
    if(playerbgm.position() == playerbgm.length()||playerbgm.position() == 0){
      playerbgm.rewind();
      playerbgm.play(); 
    }
    //player1.rewind();
}


boolean isGameOver(){
    if(gameOverKey && keyPressed && (key=='r'||key=='R') ){
        playerwin.rewind();
        mode = 2;
        snakeInit();
    }
    if(gameOverKey && keyPressed && (key=='t'||key=='T') ){
        playerwin.rewind();
        mode = 1;
        snakeInit();
    }
    return gameOverKey;
}

boolean isSnakeDie(){
    //hitting the wall
    if(snakeHeadX<0 || snakeHeadX>=width || snakeHeadY<0 || snakeHeadY>=height){
        isTwoWin = true;
        player1.rewind();
        showGameOver();
        return true;
    }

    //eat itself
    if(snakeLength>2){
        for(int i=1; i<snakeLength; i++){
            if(snakeHeadX==x[i] && snakeHeadY == y[i]){
                isTwoWin = true;
                player1.rewind();
                showGameOver();
                return true;
            }
        }
        for(int j=1; j<snakeLength2; j++){
            if(snakeHeadX==x2[j] && snakeHeadY==y2[j]){
                isTwoWin = true;
                player1.rewind();
                showGameOver();
                return true;
            }
        }
    }
    
    if(snakeHeadX2<0 || snakeHeadX2>=width || snakeHeadY2<0 || snakeHeadY2>=height){
        isOneWin = true; 
        player1.rewind();
        showGameOver();
        return true;
    }

    //eat itself
    if(snakeLength2>2){
        for(int i=1; i<snakeLength2; i++){
            if(snakeHeadX2==x2[i] && snakeHeadY2 == y2[i]){
                isOneWin = true; 
                player1.rewind();
                showGameOver();
                return true;
            }
        }
        for(int j=1; j<snakeLength; j++){
            if(snakeHeadX2==x[j] && snakeHeadY2==y[j]){
                isOneWin = true; 
                player1.rewind();
                showGameOver();
                return true;
            }
        }
    }
    
    return false;
}

void showGameOver(){
    //pushMatrix();
    gameOverKey = true;
    mode = 0;
    //bestScore = bestScore > snakeLength ? bestScore : snakeLength;
    player1.play();
    playerwin.play();
    playereat.play();
    background(0);  //black
    translate(width/2, height/2 - 50);
      //居中对齐
    textSize(84);
    if(isOneWin == true){
      image(OneWin,-450,-450,900,900);
      fill(255);  //white
      textAlign(CENTER);
      text("Purple Snake Win!", 0, 0);
      fill(255);
      textSize(30);
      //text("Score / best",0,230);
      text("Press 'R' to play two E-textile and 'T' for one E-textile.", 0, 260);}
    else if(isTwoWin == true){
      fill(0);  //white
      textAlign(CENTER);
      image(TwoWin,-450,-450,900,900);
      text("Gold Snake Win!", 0, 0);
      fill(0);
      textSize(30);
      //text("Score / best",0,230);
      text("Press 'R' to play two E-textile and 'T' for one E-textile.", 0, 260);}
    else
      {text("Ping", 0, 0);}
    //popMatrix();
}

void drawFood(int maxWidth, int maxHeight){
    fill(#ED1818);
    if(foodKey){
        foodX = int( random(0, maxWidth)/w ) * w;
        foodY = int( random(0, maxHeight)/w) * w;
    }
    image(F1,foodX, foodY, w, w);
    foodKey = false;
}

void drawItem1(int maxWidth, int maxHeight){ 
    fill(#FFFFFF);
    if(item1Key){
        item1X = int( random(0, maxWidth)/w ) * w;
        item1Y = int( random(0, maxHeight)/w) * w;
    }
    image(B1,0,0,900,900);
    image(F2,item1X, item1Y, w, w);
    fill(255);  //white
    textAlign(CENTER);
    text("Bonus!", 0, 0);
    item1Key = false;
}

void drawItem2(int maxWidth, int maxHeight){
    fill(#EE3293);
    if(item2Key){
        item2X = int( random(0, maxWidth)/w ) * w;
        item2Y = int( random(0, maxHeight)/w) * w;
    }
    image(B2,0,0,900,900);
    image(F3,item2X, item2Y, w, w);
    item2Key = false;
}