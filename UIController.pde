class UIController {
    
    boolean colorByDepth = true;
    boolean showVisitOrder = true;
    boolean showStack = true;
    float speedMultiplier = 1.0; 
    
    float speedSliderX = graphWidth + 50;
    float speedSliderY = 100;
    float speedSliderWidth = 200;
    float sliderHandleX;
    boolean draggingSlider = false;

    UIController() {
        sliderHandleX = map(speedMultiplier, 0.1, 5.0, speedSliderX, speedSliderX + speedSliderWidth);
    }

    void render() {
        fill(40, 40, 60);
        noStroke();
        rect(graphWidth, 0, uiPanelWidth, height);
        
        fill(255);
        textSize(18);
        textAlign(LEFT, TOP);
        text("닌자 DFS의 미로 탈출 🔥", graphWidth + 20, 20);

        textSize(12);
        fill(200);
        text("속도 배율: " + nf(speedMultiplier, 1, 1) + "x", graphWidth + 20, 70);
        
        fill(80);
        noStroke();
        rect(speedSliderX, speedSliderY, speedSliderWidth, 10, 5);
        
        // 슬라이더 핸들
        if (draggingSlider) {
            fill(200, 220, 255); 
        } else {
            fill(150, 180, 255);
        }
        stroke(255);
        strokeWeight(2);
        circle(sliderHandleX, speedSliderY + 5, 16);

        textSize(12);
        fill(200);
        text("< 조작법 >", graphWidth + 20, 150);
        text("Soace: 시작 / 일시정지", graphWidth + 20, 175);
        text("R: 새 미로 생성", graphWidth + 20, 195);
       
    }

    void handleMousePressed() {
        if (dist(mouseX, mouseY, sliderHandleX, speedSliderY + 5) < 10) {
            draggingSlider = true;
        }
        
    }
    
    void handleMouseDragged() {
        if (draggingSlider) {
            sliderHandleX = constrain(mouseX, speedSliderX, speedSliderX + speedSliderWidth);
            speedMultiplier = map(sliderHandleX, speedSliderX, speedSliderX + speedSliderWidth, 0.1, 5.0);
        }
    }
    
    void handleMouseReleased() {
        draggingSlider = false;
    }
}
