Graph graph;
DFSVisualizer visualizer;
UIController ui;
ParticleSystem particles;

boolean isRunning = false;
boolean isPaused = false;
int currentStep = 0;
int maxClones = 200;
int updatesPerFrame = 1;

final float moveSpeed = 0.03;
final int stopDuration = 30;
final int splitDuration = 60;

int gridSize = 40;
int nodeRadius = 15;

int canvasWidth = 1400;
int canvasHeight = 900;
int uiPanelWidth = 300;
int graphWidth = canvasWidth - uiPanelWidth;

void setup() {
  size(1400, 900);
  PFont font = createFont("맑은 고딕", 12);
  textFont(font);
  
  particles = new ParticleSystem();
  graph = new Graph();
  ui = new UIController();
  
  long seed = (long)random(1, 1000000000);
  generateMaze(seed);
}

void draw() {
  background(20, 20, 30);

  stroke(100);
  line(graphWidth, 0, graphWidth, height);

  if (isRunning && !isPaused) {
    for (int i = 0; i < updatesPerFrame; i++) {
      visualizer.update();
    }
  }

  particles.update();

  pushMatrix();

  float mazeWidth  = graph.mazeCols * gridSize;
  float mazeHeight = graph.mazeRows * gridSize;

  float offsetX = (graphWidth - mazeWidth) / 2;
  float offsetY = (height     - mazeHeight) / 2;

  translate(offsetX, offsetY);

  graph.render();
  visualizer.render();
  particles.render();

  popMatrix();

  ui.render();
}


void mousePressed() {
  ui.handleMousePressed();
}

void mouseDragged() {
  ui.handleMouseDragged();
}

void mouseReleased() {
  ui.handleMouseReleased();
}

void keyPressed() {
  if (key == ' ') {
    if (!isRunning) {
      startVisualization();
    } else {
      togglePause();
    }
  } else if (key == 's' || key == 'S') {
    stepForward();
  } else if (key == 'r' || key == 'R') {
    reset();
  }
}

void startVisualization() {
  if (!isRunning) {
    isRunning = true;
    isPaused = false;
    visualizer.start();
  }
}

void togglePause() {
  if (isRunning) {
    isPaused = !isPaused;
  }
}

void stepForward() {
  if (isRunning) {
    isPaused = true;
    visualizer.update();
  } else {
    startVisualization();
    isPaused = true;
  }
}

void reset() {
  long seed = (long)random(1, 1000000000);
  generateMaze(seed);
}

void generateMaze(long seed) {
  isRunning = false;
  isPaused = false;
  currentStep = 0;
  
  particles.clear();
  
  randomSeed(seed);
  
  int cols = 12;
  int rows = 12;
  
  graph.clear();
  graph.generateGridMaze(cols, rows, gridSize);
  
  graph.setStart(0);
  graph.setGoal(graph.nodes.size() - 1);
  
  visualizer = new DFSVisualizer(graph);
}
