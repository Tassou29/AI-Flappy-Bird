class Population {
  Bird[] birds; // Population made of birds 

  int generation = 1; // Which generation we are up to

  int bestBird = 0;// The index of the best bird in the birds[]

  int bestScoreEver = 0; // saving best score ever reached
  int currentBest = 0 ; // best score of this generation
  int birdsAlive = 0; // nb of birds alive

  float fitnessSum; // Sum of all the birds fitness (should be equals to 1.) 

  //---------------------------------------------------------------------------------------------------------------------------------------------------------  
  // Constructor
  Population(int size) {
    birds = new Bird[size];
    //initiate all the birds
    for (int i =0; i<birds.length; i++) {
      birds[i] = new Bird();
      birdsAlive = size;
    }
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  void show() {
    for (int i =0; i<birds.length; i++) {
      birds[i].show();
    }
  }
  //-------------------------------------------------------------------------------------------------------------------------------
  // Update all birds
  void update() {
    for (int i =0; i<birds.length; i++) {
      if (birds[i].alive) {
        birds[i].think();
        birds[i].update();
      }
    }
    setCurrentBest(); //after updating every bird renew the best bird
  }
  //-------------------------------------------------------------------------------------------------------------------------------
  // Update AND SHOW all birds
  void updateAndShow() {
    for (int i =0; i<birds.length; i++) {
      if (birds[i].alive) {
        birds[i].think();
        birds[i].update();
        birds[i].show(); // Show the bird
      }
    }
    setCurrentBest(); //after updating every bird renew the best bird
  }
  //-------------------------------------------------------------------------------------------------------------------------------
  // Returns whether all the birds are dead
  boolean allBirdsDead() {
    for (int i=0; i<birds.length; i++) {
      if (birds[i].alive == true) {
        return false; // ==> Birds still alive
      }
    } // => They're all dead.
    return true;
  }
  //-------------------------------------------------------------------------------------------------------------------------------
  // Gets the next generation of birds
  void naturalSelection() {
    calculateFitnessSum(); // Calculate fitness of old generation
    setBestBird(); // selecting the best bird of the population
    Bird[] newBirds = new Bird[birds.length]; // Creating next gen
    birdsAlive = birds.length; // reseting alive counter

    // Cheking if the new champion is better than the new one
    if (birds[bestBird].score >= bestScoreEver) {
      //the new champion lives on 
      newBirds[0] = birds[bestBird].clone();
      newBirds[0].isBest = true;
    } else {
      //the old champion stays 
      newBirds[0] = birds[0].clone();
      newBirds[0].isBest = true;
    }

    //initiate all the other birds
    for (int i = 1; i<newBirds.length; i++) {
      // select 2x parents based on fitness
      Bird parent1 = selectParent();
      Bird parent2 = selectParent();

      // Crossover the 2 Birds to create the child
      Bird child = parent1.crossover(parent2);
      // Mutate the child 
      child.mutate(globalMutationRate);
      //add the child to the next generation
      newBirds[i] = child;

      //uncomment line below to do natural selection without crossover
      //newBirds[i] = selectParent().clone().mutate(globalMutationRate);
    }

    birds = newBirds.clone();
    generation ++;
  }
  //--------------------------------------------------------------------------------------------------------------------------------------
  // Calculate the total fitness of the generation
  void calculateFitnessSum() {
    fitnessSum = 0;
    for (int i =0; i<birds.length; i++) {
      fitnessSum += birds[i].score; // adding all the score
    }
    for (int i =0; i<birds.length; i++) {
      birds[i].fitness = ((birds[i].score)/fitnessSum) ; // fitness of each bird = its score / sumFitness
    }
    currentBest = 0; //reseting variable currentBest
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------
  // Finds the bird with the highest fitness and sets it as the best bird
  void setBestBird() {
    float max = 0;
    int maxIndex = 0;
    for (int i =0; i<birds.length; i++) {
      if (birds[i].fitness>max) {
        max = birds[i].fitness; // Selecting best bird 
        maxIndex = i; // And its index
      }
    }
    bestBird = maxIndex;
    if (birds[bestBird].score > bestScoreEver) {
      bestScoreEver = birds[bestBird].score; // saving best score ever
      // Checking against best score saved in file 
      Table t = loadTable("data/BestBirdStats.csv","header, csv");
      for (TableRow row : t.rows()) {
        float bestScoreSaved = row.getFloat("Top Score");
        if (bestScoreSaved<bestScoreEver) {
          birds[bestBird].saveBestBird(bestScoreEver); // Saving the best bird ever
          println("We've saved a new best bird ever! Score :", bestScoreEver);
        }
      }
    }
  }

  //-------------------------------------------------------------------------------------------------------------------------------------

  //chooses dot from the population to return randomly(considering fitness)
  //this function works by randomly choosing a value between 0 and the sum of all the fitnesses
  //then go through all the dots and add their fitness to a running sum and if that sum is greater than the random value generated that dot is chosen
  //since dots with a higher fitness function add more to the running sum then they have a higher chance of being chosen
  Bird selectParent() {
    float rand = random(1);
    float runningSum = 0;
    for (int i =0; i<birds.length; i++) {
      runningSum+= birds[i].fitness;
      if (runningSum > rand) {
        return birds[i];
      }
    }
    println("Fuck ..zs");//should never get to this point
    return null;
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------
  // Finds the bird with the highest fitness and sets it as the best bird
  void setCurrentBest() {
    if (!done()) { //if any birds alive
      float max = 0;
      for (int i =0; i<birds.length; i++) {
        if (birds[i].score > max) {
          max = birds[i].score;
        }
      }
      if (max > currentBest) {
        currentBest = floor(max);
      }
      if (currentBest > bestScoreEver) {
        bestScoreEver = currentBest;
      }
    }
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------    
  // Test if at least one bird of this population is still alive
  boolean done() {
    for (int i = 0; i< birds.length; i++) {
      if (birds[i].alive) {
        return false; // He's alive!
      }
    }
    return true; // They're all dead
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------
}
