class Tree {

  int treeHeight = 0; // Height of bottom tree
  int treeWidth = 52; // Width of bottom tree

  PVector treePos; // Position of tree
  PVector treeVel; // Velocity of tree
  PVector treeAcc; // Acceleration of tree

  PVector upTreePos; // Position of tree

  PImage bottom_tree = loadImage("image/bottom_tree.png");
  PImage top_tree = loadImage("image/top_tree.png");

  int treeGap = 125 ; // Gap between bottom and top tree 

  int upTreeHeight = 0; // Height of the up tree

  //------------------------------------------------------------------------------------------------------------------
  // Constructor
  Tree() {

    // Determining tree height randomly : 700/2 = 350 - gap 50 : 0 - 300
    treeHeight = floor(random(50, 600-treeGap));

    // Start the tree at the right of the window with velocity
    treePos = new PVector(width + treeWidth, height-100-treeHeight); // 800-100-50 : 
    treeVel = new PVector(0, 0);
    treeAcc = new PVector(-1, 0);

    // Determining the up tree height; 
    upTreeHeight = height - 100 - treeGap - treeHeight;
    // Start the up tree at the right of the window with velocity
    upTreePos = new PVector(width + treeWidth, 0);
  }
  //------------------------------------------------------------------------------------------------------------------

  // Draws the tree on the screen
  void show() {
    //fill(treeColor);
    //rect(treePos.x, treePos.y, treeWidth, treeHeight);
    //rect(upTreePos.x, upTreePos.y, treeWidth, upTreeHeight);
    image(bottom_tree, treePos.x, treePos.y);
    image(top_tree, treePos.x, treePos.y - 668 - treeGap);
    image(ground, treePos.x-1000, 700);
  }
  //-----------------------------------------------------------------------------------------------------------------
  // Move tree
  void move() {
    if (!population.allBirdsDead()) {
      treePositionCheck(); // Check if tree out of screen. yes
      // Apply the acceleration and move the tree
      treeVel.add(treeAcc);
      treeVel.limit(3); // Not too fast
      treePos.add(treeVel);
      // Same on up tree
      upTreePos.add(treeVel);
    }
  }
  //-----------------------------------------------------------------------------------------------------------------
  // When tree out of screen : create a new tree
  void treePositionCheck() {
    if (treePos.x < -1.0 * treeWidth) { // When tree disapear from screen : 
      treeNum = treeNum + 1 ; // Incrementing tree counter
      tree = new Tree(); // Creating a new tree
    }
  }
}
