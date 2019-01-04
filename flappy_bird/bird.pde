class Bird {
  NeuralNet brain;
  PVector pos;
  PVector vel;
  PVector acc;

  PVector gravity = new PVector (0, 0.5) ; // Acceleration = gravity
  PVector jumpAcc = new PVector (0, -20) ; // Acceleration cause by jump

  int birdSize = 30; // Size of the bird
  int treePassed = 0; // Number of tree passed
  int score = 0 ; // Score counter
  
  boolean alive = true;
  boolean isBest = false;// True if this bird is the best bird from the previous generation

  float[] decision = new float[1]; // The output of the neural net
  float[] inputs = new float[5]; // The inputs for the neural net
  float fitness = 0 ; // Fitness counter
  
  PImage flappyUp = loadImage("image/flappy-up.png");
  PImage flappyMiddle = loadImage("image/flappy-middle.png");
  PImage flappyDown = loadImage("image/flappy-down.png");

  // Constructor
  Bird() {
    pos = new PVector(200, 400);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);

    brain = new NeuralNet(5, 5, 1); // Create a neural net with 5 input neurons 5 hidden neurons and 1 output neuron
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  

  // Mutates neural net
  void mutate(float mr) {
    brain.mutate(mr);
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  


  //-----------------------------------------------------------------------------------------------------------------
  // Draws the bird on the screen
  void show() {
    //fill(0, 85, 255);
    //ellipse(pos.x, pos.y, 33, 23);
    // Draw correct skin
    double skinChooser;
    skinChooser = frameCount % 20;
    imageMode(CENTER);
    if (skinChooser <= 5) {
      image(flappyUp, pos.x, pos.y);
    } else if (skinChooser <= 10) {
      image(flappyMiddle, pos.x, pos.y);
    } else if (skinChooser <= 15) {
      image(flappyDown, pos.x, pos.y);
    } else {
      image(flappyMiddle, pos.x, pos.y);
    }
    imageMode(CORNER);
  }

  //-----------------------------------------------------------------------------------------------------------------
  // Move bird
  void move() {
    if (!jumpCommand) { // No Jump : apply the gravity and move the bird
      acc = gravity ;
      vel.add(acc);
      vel.limit(5); // Not too fast
      pos.add(vel);
    } else { // Jump! : apply the gravity of jump  
      acc = jumpAcc ;
      vel.add(acc);
      vel.limit(15); // Not too fast
      pos.add(vel);
      jumpCommand = false; // Once jump accelleration applied, remove jump command
    }
  }

  //-----------------------------------------------------------------------------------------------------------------
  // Update bird : checking for collisions
  void update() {
    if (alive) {
      score++; // => score gets +1 everytime update function is called
      // if tree is passed, then +200 points on score 
      if (pos.x > tree.treePos.x && treePassed < treeNum) { // Only +200pts per tree
        treePassed++; 
        score = score + 200;
      }

      move();
      
      // Checking if bird is touching top or bottom of the game
      if ((pos.y < (birdSize/2)) || (pos.y > (700 - birdSize/2))) {
        alive = false; // killing the bird
        population.birdsAlive--; // Removing one bird from counter
      }
      // Checking if bird is touching Bottom tree
      if ((pos.x < tree.treePos.x + tree.treeWidth + birdSize/2) && (pos.y > tree.treePos.y - birdSize/3) && (pos.x > tree.treePos.x - birdSize/2) && pos.y < 700) {
        alive = false; // killing the bird
        population.birdsAlive--; // removing one bird from counter
      }
      // Checking if bird is touching Top tree
      if ((pos.x < tree.treePos.x + tree.treeWidth + birdSize/2) && (pos.y < tree.upTreePos.y + tree.upTreeHeight + birdSize/3) && (pos.x > tree.treePos.x - birdSize/2) && pos.y < 700) {
        alive = false; // killing the bird
        population.birdsAlive--; // removing one bird from counter
      }
    }
  }
  //---------------------------------------------------------------------------------------------------------------------------------------
  // Think fonction for the neural network
  void think() {
    //get the output of the neural network
    // => Cleaning data : make sure inputs are between 0 & 1
    inputs[0] = pos.y / height; // y location of bird 
    inputs[1] = tree.treePos.x / width; // x location of pipe
    float topSide = (tree.treePos.y - birdSize/3)/height;
    inputs[2] = topSide; // y location of top pipe
    float bottomSide = (tree.upTreePos.y + tree.upTreeHeight + birdSize/3)/height;
    inputs[3] = bottomSide; // y location of bottow pipe
    float yVelocity = vel.y / 15;
    inputs[4] = yVelocity ; // y velocity of the bird (max vel = 15 / normalisation)
    decision = brain.output(inputs);
    if (decision[0] > 0.5) {
      jumpCommand = true;
    } else {
      jumpCommand = false;
    }
  }
  //---------------------------------------------------------------------------------------------------------------------------------------
  // Returns a clone of the bird
  Bird clone() {
    Bird clone = new Bird();
    clone.brain = brain.clone();
    clone.alive = true;
    return clone;
  }
  //---------------------------------------------------------------------------------------------------------------------------------------
  // Crossover function for genetic algorithm
  Bird crossover(Bird partner) {
    Bird child = new Bird(); 

    child.brain = brain.crossover(partner.brain);
    return child;
  }
  //---------------------------------------------------------------------------------------------------------------------------------------
  // Saves the bird to a file by converting it to a table
  void saveBestBird(int score) {
    // Save the birds top score
    Table birdStats = new Table(); 
    birdStats.addColumn("Top Score", Table.INT);
    TableRow row = birdStats.addRow();
    row.setInt("Top Score", score);
    saveTable(birdStats, "data/BestBirdStats.csv");
    // save bird brain 
    saveTable(brain.NetToTable(), "data/BestBird.csv"); // converting NN to table
  }
  //---------------------------------------------------------------------------------------------------------------------------------------

  // Return the bird saved in the parameter position
  Bird loadBird() {
    Bird load = new Bird();
    Table t = loadTable("data/BestBird.csv");
    load.brain.TableToNet(t); // converting table to NN
    return load;
  }
  //---------------------------------------------------------------------------------------------------------------------------------------
}
