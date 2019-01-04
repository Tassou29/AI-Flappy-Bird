Tree tree; 
Population population;
BestBird bestBird;

boolean jumpCommand = false; // Command ordering the bird to jump or not
boolean showingBestBird = false ; // Switch to display current best bird

PImage bg; // Background picture
PImage ground; // Moving ground picture
PImage draw_data ; // Data pic
PImage drawa_data_legend ; // Legend data pic

int framerate = 150 ; // Draw framerate
int treeNum = 1 ; // Tree counter 
int populationSize = 500 ; // Nb of birds created in each population
int bestScoreSaved = 0; // saved best score in local file

float globalMutationRate = 0.01; // Mutation rate : 1%

void setup() {
  size(1000, 800); // Size of the window
  frameRate(framerate);
  bg = loadImage("image/bg.png"); // Loading background image
  ground = loadImage("image/ground.png"); // Loading Ground image
  draw_data = loadImage("image/draw_data.png"); // Loading data display frame
  drawa_data_legend = loadImage("image/draw_data_legend.png"); // Loading legend data display frame 
  population = new Population(populationSize); // Creating 'X' birds
  tree = new Tree(); // Creating a new tree
}

void draw() {
  if (!showingBestBird) { // While 'showingBestBird' is false :
    if (population.allBirdsDead()) { // If all the birds are dead :
      population.naturalSelection(); // Natural Selection + Creating new Gen
      tree = new Tree(); // Creata a new tree
      treeNum = 1; // Reset tree counter
      drawData(); // Draw current data
    } else { // Birds are stil alive
      frameRate(framerate);
      background(bg);
      population.updateAndShow(); // Updating and showing population
      tree.move(); // moving tree (without showing)
      tree.show(); // showing tree
      drawData(); // Draw current data
    }
  } else { // If showingBestBird is activated :
    if (bestBird.alive) {
      frameRate(framerate);
      background(bg);
      bestBird.think();
      bestBird.update();
      bestBird.show();
      tree.move(); // moving tree (without showing)
      tree.show(); // showing tree
      drawDataLegend(); // Draw current data for the Legend
    } else {
      showingBestBird = !showingBestBird; // Going back to game
    }
  }
}

//---------------------------------------------------------------------------------------------------------------------------------------------------------  
void keyPressed() {
  //------------------------------------------------------------------------
  if (key=='K') { // Killing switch
    for (int i =0; i<population.birds.length; i++) {
      population.birds[i].alive = false;
    }
    population.naturalSelection();
  }
  //------------------------------------------------------------------------
  if (key=='r') { // Restart the game
    population = new Population(populationSize); // Creating 'X' birds
    tree = new Tree(); // Creating a new tree
  }
  //------------------------------------------------------------------------
  if (key=='B') { // showing the best bird
    Bird load = new Bird();
    //println("Bird load = new Bird();");
    Table t = loadTable("data/BestBird.csv");
    load.brain.TableToNet(t); // converting table to NN
    bestBird = new BestBird(); // Creating a new best bird
    bestBird.bestBrain = load.brain.clone();

    Table tableStat = loadTable("data/BestBirdStats.csv", "header, csv");
    for (TableRow row : tableStat.rows()) {
      bestScoreSaved = row.getInt("Top Score");
    }

    tree = new Tree(); // Creating a new tree
    showingBestBird = !showingBestBird;
  }
  //------------------------------------------------------------------------
  if (key=='6') {
    framerate = framerate + 5;
    println("Framerate : ", framerate);
  }
  if (key=='4') {
    framerate = framerate - 5;
    println("Framerate : ", framerate);
  }
  //------------------------------------------------------------------------
  if (key=='S') { // Saving the best bird of current population
    float max = 0;
    int maxIndex = 0;
    for (int i =0; i<population.birds.length; i++) {
      if (population.birds[i].score>max) {
        max = population.birds[i].score; // Selecting best bird 
        maxIndex = i; // And its index
      }
    }
    int score = population.birds[maxIndex].score;
    population.birds[maxIndex].saveBestBird(score);
    println("We've save a new bird. Score :", score);
  }
}

//---------------------------------------------------------------------------------------------------------------------------------------------------------
void drawData() {
  image(draw_data, 0, 700);
  textSize(15);
  fill(167, 131, 37);
  String text = str(population.generation);
  text(text, 174, 734);
  text = str(population.currentBest); 
  text(text, 15, 744);
  text = str(population.bestScoreEver); 
  text(text, 15, 784);
  text = str(population.birdsAlive); 
  text(text, 174, 776);
}
//---------------------------------------------------------------------------------------------------------------------------------------------------------
void drawDataLegend() {
  image(drawa_data_legend, 0, 700);
  textSize(15);
  fill(167, 131, 37);
  String text = str(bestBird.score);
  text(text, 15, 744);
  text = str(bestScoreSaved);
  text(text, 15, 784);
}
