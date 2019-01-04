class BestBird {
  NeuralNet bestBrain;
  Bird bird;
  PVector pos;
  PVector vel;
  PVector acc;

  PVector gravity = new PVector (0, 0.5) ; // Acceleration = gravity
  PVector jumpAcc = new PVector (0, -20) ; // Acceleration cause by jump

  int birdSize = 30; // size of the bird
  int treePassed = 0; // number of tree passed

  boolean alive = true;

  float[] decision ; // the output of the neural net
  float[] inputs = new float[5]; //the inputs for the neural net

  int score = 0 ; // score counter

  PImage flappyUp = loadImage("image/best_flappy-up.png");
  PImage flappyMiddle = loadImage("image/best_flappy-middle.png");
  PImage flappyDown = loadImage("image/best_flappy-down.png");

  // Constructor
  BestBird() {
    pos = new PVector(200, 400);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);

    bestBrain = new NeuralNet(5, 5, 1); //create a neural net with 5 input neurons 5 hidden neurons and 1 output neuron
  }
  //-----------------------------------------------------------------------------------------------------------------
  //draws the bird on the screen
  void show() {
    //fill(180, 85, 255);
    //ellipse(pos.x, pos.y, birdSize, birdSize);
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
  // move bird
  void move() {
    if (!jumpCommand) { // No Jump : apply the gravity and move the dot
      acc = gravity ;
      vel.add(acc);
      vel.limit(5); //not too fast
      pos.add(vel);
    } else { // Jump! : apply the gravity of jump  
      acc = jumpAcc ;
      vel.add(acc);
      vel.limit(15); //not too fast
      pos.add(vel);
      jumpCommand = false; // Once jump accelleration applied, remove jump command
    }
  }
  //-----------------------------------------------------------------------------------------------------------------
  // update bird : checking for collisions
  void update() {
    if (alive) {
      score++; // => score gets +1 everytime update function is called
      // if tree is passed, then +200 points on score 
      if (pos.x > tree.treePos.x && treePassed < treeNum) { // only +200pts per tree
        treePassed++; 
        score = score +200;
      }
      move();
      // Checking if bird is touching top or bottom of the game
      if ((pos.y < (birdSize/2)) || (pos.y > (height - birdSize/2 -100))) {
        alive = false; // killing the bird
      }
      // Checking if bird is touching bottom tree
      if ((pos.x < tree.treePos.x + tree.treeWidth + birdSize/2) && (pos.y > tree.treePos.y - birdSize/3) && (pos.x > tree.treePos.x - birdSize/2) && pos.y < 700) {
        alive = false; // killing the bird
      }
      // Checking if bird is touching top tree
      if ((pos.x < tree.treePos.x + tree.treeWidth + birdSize/2) && (pos.y < tree.upTreePos.y + tree.upTreeHeight + birdSize/3) && (pos.x > tree.treePos.x - birdSize/2) && pos.y < 700) {
        alive = false; // killing the bird
      }
    }
  }
  //---------------------------------------------------------------------------------------------------------------------------------------
  // think fonction for the neural network
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
    decision = bestBrain.output(inputs);
    if (decision[0] > 0.5) {
      jumpCommand = true;
    } else {
      jumpCommand = false;
    }
  }
  //---------------------------------------------------------------------------------------------------------------------------------------
}
