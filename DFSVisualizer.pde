class DFSVisualizer {
    Graph graph;
    ArrayList<Clone> activeClones;
    ArrayList<Clone> fadingClones;
    boolean useIterativeMode; 
    boolean foundGoal;
    int visitCounter;
    int stepCount;
    int animationTimer;

    DFSVisualizer(Graph g) {
        this.graph = g;
        this.activeClones = new ArrayList<Clone>();
        this.fadingClones = new ArrayList<Clone>();
        this.useIterativeMode = true;
        this.foundGoal = false;
        this.visitCounter = 0;
        this.stepCount = 0;
        this.animationTimer = 0;
    }

    void start() {
        reset();
        Node startNode = graph.getStartNode();
        if (startNode != null) {
            Clone initialClone = new Clone(startNode, null, 0);
            activeClones.add(initialClone);
            startNode.visited = true;
            startNode.visitOrder = visitCounter++;
        }
    }

    void reset() {
        activeClones.clear();
        fadingClones.clear();
        foundGoal = false;
        visitCounter = 0;
        stepCount = 0;
        animationTimer = 0;
        graph.reset();
    }

    void update() {
        if (foundGoal || activeClones.size() == 0) {
            return;
        }

        stepCount++;

        while (activeClones.size() > maxClones) {
            Clone removed = activeClones.remove(0); 
            killClone(removed);
        }

        Clone currentClone = activeClones.get(activeClones.size() - 1);

        if (currentClone.isMoving) {
            currentClone.moveProgress += moveSpeed * ui.speedMultiplier;

            if (currentClone.moveProgress >= 1.0) {
                currentClone.isMoving = false;
                currentClone.moveProgress = 0;
                currentClone.current = currentClone.target;
                currentClone.target = null;
                animationTimer = (int)((stopDuration + splitDuration) / ui.speedMultiplier);
                currentClone.isSplitting = false;
            }
            return;
        }

        if (animationTimer > 0) {
            animationTimer--;
            int adjustedStopDuration = (int)(stopDuration / ui.speedMultiplier);
            
            if (animationTimer > adjustedStopDuration) {
                currentClone.isSplitting = true; 
            } else {
                currentClone.isSplitting = false;
            }
            if (animationTimer > 0) return;
        }

        if (currentClone.current == graph.getGoalNode()) {
            foundGoal = true;
            markSuccessPath(currentClone);
            return;
        }

        ArrayList<Node> unvisitedNeighbors = new ArrayList<Node>();
        for (Node neighbor : currentClone.current.neighbors) {
            if (!neighbor.visited) {
                unvisitedNeighbors.add(neighbor);
            }
        }

        if (unvisitedNeighbors.size() == 0) {
            activeClones.remove(activeClones.size() - 1); 
            
            if (activeClones.size() > 0) {
                Clone parentClone = activeClones.get(activeClones.size() - 1);
                currentClone.setReturnPath(parentClone.current);
            } else {
                currentClone.setReturnPath(null); 
            }
            killClone(currentClone); 
        } 
        // 탐색 진행 (갈림길)
        else {
            // 첫 번째 이웃: 현재 클론이 이어서 탐색
            Node firstNeighbor = unvisitedNeighbors.get(0);
            firstNeighbor.visited = true;
            firstNeighbor.visitOrder = visitCounter++;

            currentClone.target = firstNeighbor;
            currentClone.isMoving = true;
            currentClone.path.add(firstNeighbor);

            // 나머지 이웃들: 새로운 분신(클론) 생성해 스택에 Push
            for (int i = 1; i < unvisitedNeighbors.size(); i++) {
                Node neighbor = unvisitedNeighbors.get(i);
                neighbor.visited = true;
                neighbor.visitOrder = visitCounter++;

                Clone newClone = new Clone(currentClone.current, currentClone, currentClone.depth + 1);
                newClone.target = neighbor;
                newClone.isMoving = true; // 생성과 동시에 이동 시작
                newClone.path = (ArrayList<Node>)currentClone.path.clone(); // 경로 복사
                newClone.path.add(neighbor);

                activeClones.add(newClone); // 스택에 Push
                createSplitEffect(currentClone.current.pos);
            }
        }
    }

    void killClone(Clone clone) {
        clone.alive = false;
        clone.fadeAlpha = 255;
        fadingClones.add(clone);

        PVector pos = clone.isMoving && clone.target != null ?
            PVector.lerp(clone.current.pos, clone.target.pos, clone.moveProgress) :
            clone.current.pos;
        createDeathEffect(pos);
    }

    void markSuccessPath(Clone clone) {
        for (Node node : clone.path) {
            node.onSuccessPath = true;
        }
        createSuccessEffect(clone.current.pos);
    }

    void createSplitEffect(PVector pos) {
        for (int i = 0; i < 8; i++) {
            float angle = random(TWO_PI);
            PVector vel = PVector.fromAngle(angle).mult(random(1, 3));
            particles.add(new Particle(pos.copy(), vel, color(150, 150, 255), 30));
        }
    }

    void createDeathEffect(PVector pos) {
        for (int i = 0; i < 12; i++) {
            float angle = random(TWO_PI);
            PVector vel = PVector.fromAngle(angle).mult(random(0.5, 2));
            particles.add(new Particle(pos.copy(), vel, color(100, 100, 100), 40));
        }
    }

    void createSuccessEffect(PVector pos) {
        for (int i = 0; i < 30; i++) {
            float angle = random(TWO_PI);
            PVector vel = PVector.fromAngle(angle).mult(random(2, 5));
            particles.add(new Particle(pos.copy(), vel, color(255, 215, 0), 60));
        }
    }


    void render() {
        for (Clone clone : fadingClones) {
            clone.render();
            if (!clone.alive && clone.returnPath != null) {
                drawReturnPath(clone); 
            }
        }

        ArrayList<Clone> fadedOut = new ArrayList<Clone>();
        for (Clone clone : fadingClones) {
            clone.fadeAlpha -= 5 * ui.speedMultiplier;
            if (clone.fadeAlpha <= 0) {
                fadedOut.add(clone);
            }
        }
        fadingClones.removeAll(fadedOut);

        for (int i = 0; i < activeClones.size(); i++) {
            Clone clone = activeClones.get(i);
            
            if (i == activeClones.size() - 1) {
                clone.render(); 
            } else {
                renderWaitingClone(clone); 
            }
        }

        if (ui.showStack) {
            renderStackVisualization();
        }
    }

    void renderWaitingClone(Clone clone) {
        PVector pos = clone.current.pos; 
        color c = clone.getDepthColor();
        
        fill(red(c), green(c), blue(c), 70); 
        stroke(255, 90);
        strokeWeight(1);
        circle(pos.x, pos.y, 10);
        
    }

    void drawReturnPath(Clone clone) {
        Node fromNode = clone.current;
        Node toNode = clone.returnPath;

        if (fromNode == null || toNode == null) return;

        stroke(255, 100, 100, clone.fadeAlpha); 
        strokeWeight(2);

        float dashLen = 5;
        float gapLen = 5;
        float totalLen = dist(fromNode.pos.x, fromNode.pos.y, toNode.pos.x, toNode.pos.y);
        float dx = toNode.pos.x - fromNode.pos.x;
        float dy = toNode.pos.y - fromNode.pos.y;

        pushMatrix();
        translate(fromNode.pos.x, fromNode.pos.y);
        rotate(atan2(dy, dx));

        float currentDist = 0;
        while (currentDist < totalLen) {
            line(currentDist, 0, min(currentDist + dashLen, totalLen), 0);
            currentDist += dashLen + gapLen;
        }

        popMatrix();
    }

    void renderStackVisualization() {
        pushMatrix();
        translate(graphWidth + 20, 250); 

        fill(40, 40, 60, 200);
        stroke(100, 100, 150);
        rect(0, 0, uiPanelWidth - 40, 400);

        fill(255);
        textAlign(LEFT, TOP);
        textSize(14);
        text("활성 분신 스택 (LIFO)", 10, 10);

        int y = 35;
        int displayCount = min(15, activeClones.size());

        for (int i = 0; i < displayCount; i++) {
            Clone clone = activeClones.get(activeClones.size() - 1 - i);

            color c = clone.getDepthColor();
            
            if (i == 0) {
                 fill(red(c), green(c), blue(c), 220);
                 stroke(255, 255, 150);
                 rect(10, y, uiPanelWidth - 60, 20);
            } else {
                 fill(red(c), green(c), blue(c), 100);
                 noStroke();
                 rect(10, y, uiPanelWidth - 60, 20);
            }

            fill(255);
            textSize(10);
            text("깊이:" + clone.depth + " 노드:" + clone.current.id, 15, y + 5);

            y += 22;
        }

        if (activeClones.size() > displayCount) {
            fill(200);
            text("... +" + (activeClones.size() - displayCount) + " more", 15, y);
        }

        popMatrix();
    }
}
