class UIController {
  boolean showVisitOrder = false;
  boolean showStack = false;
  boolean colorByDepth = true;
  float speedMultiplier = 1.0;
  
  UIController() {
    showVisitOrder = false;
    showStack = false;
    colorByDepth = true;
    speedMultiplier = 1.0;
  }
  
  void render() {
    fill(30, 30, 40);
    noStroke();
    rect(graphWidth, 0, uiPanelWidth, height);
    
    fill(255);
    textAlign(LEFT, TOP);
    textSize(20);
    text("DFS 닌자 미로 탈출", graphWidth + 20, 5);
    
    int infoY = 80;
    fill(50, 50, 70);
    rect(graphWidth + 20, infoY, 260, 250);
    
    fill(200, 200, 255);
    textSize(15);
    text("현재 상태", graphWidth + 30, infoY + 10);
    
    fill(255);
    textSize(15);
    int lineY = infoY + 35;
    
    text("상태: " + (isRunning ? (isPaused ? "일시정지" : "실행 중") : "대기"), 
         graphWidth + 30, lineY);
    lineY += 25;
    
    text("활성 분신: " + visualizer.activeClones.size(), 
         graphWidth + 30, lineY);
    lineY += 25;
    
    text("페이딩 분신: " + visualizer.fadingClones.size(), 
         graphWidth + 30, lineY);
    lineY += 25;
    
    text("방문한 노드: " + visualizer.visitCounter + " / " + graph.nodes.size(), 
         graphWidth + 30, lineY);
    lineY += 25;
    
    text("스텝 수: " + visualizer.stepCount, 
         graphWidth + 30, lineY);
    lineY += 25;
    
    text("목표 발견: " + (visualizer.foundGoal ? "예" : "아니오"), 
         graphWidth + 30, lineY);
    lineY += 30;
    
    fill(200, 200, 255);
    textSize(15);
    text("키 입력:", graphWidth + 30, lineY);
    lineY += 18;
    fill(255);
    textSize(15);
    text("Space: 시작/일시정지", graphWidth + 30, lineY);
    lineY += 18;
    text("R: 새 미로 생성(초기화)", graphWidth + 30, lineY);
  }
  
  void handleMousePressed() { }
  void handleMouseDragged() { }
  void handleMouseReleased() { }
}
