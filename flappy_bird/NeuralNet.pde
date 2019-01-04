class NeuralNet {

  int iNodes; //No. of input nodes : => 5x inputs
  // y location of bird
  // x location of pipe 
  // y location of top pipe
  // y location of bottow pipe 
  // y Velocity of the bird 
  int hNodes; // No. of hidden nodes : => 5x hidden nodes
  int oNodes; // No. of output nodes : 1 output between 0-1 : < 0.5 don't jump, > 0.5 jump

  Matrix whi; // Matrix containing weights between the input nodes and the hidden nodes
  Matrix whh; // Matrix containing weights between the hidden nodes and the second layer hidden nodes
  Matrix woh; // Matrix containing weights between the second hidden layer nodes and the output nodes

  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  // Constructor
  NeuralNet(int inputs, int hiddenNo, int outputNo) {
    // Set dimensions from parameters
    iNodes = inputs;
    oNodes = outputNo;
    hNodes = hiddenNo;

    // Create first layer weights 
    // Included bias weight
    whi = new Matrix(hNodes, iNodes +1);

    // Create second layer weights
    // Include bias weight
    whh = new Matrix(hNodes, hNodes +1);

    // Create second layer weights
    // Include bias weight
    woh = new Matrix(oNodes, hNodes +1);  

    // Set the matricies to random values
    whi.randomize();
    whh.randomize();
    woh.randomize();
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------

  // Mutation function for genetic algorithm
  void mutate(float mr) {
    //mutates each weight matrix
    whi.mutate(mr);
    whh.mutate(mr);
    woh.mutate(mr);
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------

  // Calculate the output values by feeding forward through the neural network
  float[] output(float[] inputsArr) {

    // Convert Array to Matrix
    // Note woh has nothing to do with it its just a function in the Matrix class
    Matrix inputs = woh.singleColumnMatrixFromArray(inputsArr);

    // Add bias 
    Matrix inputsBias = inputs.addBias();


    //------- Calculate the guessed output -------\\
    // Apply layer one weights to the inputs
    Matrix hiddenInputs = whi.dot(inputsBias);

    // Pass through activation function (sigmoid)
    Matrix hiddenOutputs = hiddenInputs.activate();

    // Add bias
    Matrix hiddenOutputsBias = hiddenOutputs.addBias();

    // Apply layer two weights
    Matrix hiddenInputs2 = whh.dot(hiddenOutputsBias);
    Matrix hiddenOutputs2 = hiddenInputs2.activate();
    Matrix hiddenOutputsBias2 = hiddenOutputs2.addBias();

    // Apply level three weights
    Matrix outputInputs = woh.dot(hiddenOutputsBias2);
    // Pass through activation function (sigmoid)
    Matrix outputs = outputInputs.activate();

    // Convert to an Array and Return
    return outputs.toArray();
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  
  // Crossover function for genetic algorithm
  NeuralNet crossover(NeuralNet partner) {

    // Creates a new child with layer matrices from both parents
    NeuralNet child = new NeuralNet(iNodes, hNodes, oNodes);
    child.whi = whi.crossover(partner.whi);
    child.whh = whh.crossover(partner.whh);
    child.woh = woh.crossover(partner.woh);
    return child;
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  // Return a neural net which is a clone of this Neural net
  NeuralNet clone() {
    NeuralNet clone  = new NeuralNet(iNodes, hNodes, oNodes); 
    clone.whi = whi.clone();
    clone.whh = whh.clone();
    clone.woh = woh.clone();

    return clone;
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  
  // Converts the weights matrices to a single table 
  // Used for storing the snakes brain in a file
  Table NetToTable() {

    // Create table
    Table t = new Table();

    // Convert the matricies to an array 
    float[] whiArr = whi.toArray();
    float[] whhArr = whh.toArray();
    float[] wohArr = woh.toArray();

    // Set the amount of columns in the table
    for (int i = 0; i< max(whiArr.length, whhArr.length, wohArr.length); i++) {
      t.addColumn();
    }

    // Set the first row as whi
    TableRow tr = t.addRow();

    for (int i = 0; i< whiArr.length; i++) {
      tr.setFloat(i, whiArr[i]);
    }

    // Set the second row as whh
    tr = t.addRow();

    for (int i = 0; i< whhArr.length; i++) {
      tr.setFloat(i, whhArr[i]);
    }

    // Set the third row as woh
    tr = t.addRow();

    for (int i = 0; i< wohArr.length; i++) {
      tr.setFloat(i, wohArr[i]);
    }

    //Return table
    return t;
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  

  // Takes in table as parameter and overwrites the matrices data for this neural network
  // Used to load snakes from file
  void TableToNet(Table t) {

    // Create arrays to tempurarily store the data for each matrix
    float[] whiArr = new float[whi.rows * whi.cols];
    float[] whhArr = new float[whh.rows * whh.cols];
    float[] wohArr = new float[woh.rows * woh.cols];

    // Set the whi array as the first row of the table
    TableRow tr = t.getRow(0);

    for (int i = 0; i< whiArr.length; i++) {
      whiArr[i] = tr.getFloat(i);
    }

    // Set the whh array as the second row of the table
    tr = t.getRow(1);

    for (int i = 0; i< whhArr.length; i++) {
      whhArr[i] = tr.getFloat(i);
    }

    // Set the woh array as the third row of the table

    tr = t.getRow(2);

    for (int i = 0; i< wohArr.length; i++) {
      wohArr[i] = tr.getFloat(i);
    }

    // Convert the arrays to matrices and set them as the layer matrices 
    whi.fromArray(whiArr);
    whh.fromArray(whhArr);
    woh.fromArray(wohArr);
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------
}
