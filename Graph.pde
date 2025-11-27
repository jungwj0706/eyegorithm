class Graph {
    ArrayList<Node> nodes;
    ArrayList<Edge> edges;
    int startNodeId;
    int goalNodeId;
    
    int mazeCols;
    int mazeRows;
    
    Graph() {
        nodes = new ArrayList<Node>();
        edges = new ArrayList<Edge>();
        startNodeId = -1;
        goalNodeId = -1;
        mazeCols = 0;
        mazeRows = 0;
    }
    
    void clear() {
        nodes.clear();
        edges.clear();
        startNodeId = -1;
        goalNodeId = -1;
        mazeCols = 0;
        mazeRows = 0;
    }
    
    void reset() {
        for (Node n : nodes) {
            n.visited = false;
            n.visitOrder = -1;
            n.onSuccessPath = false;
        }
    }
    
    Node addNode(float x, float y) {
        Node n = new Node(nodes.size(), x, y);
        nodes.add(n);
        return n;
    }
    
    void addEdge(int from, int to) {
        if (from >= 0 && from < nodes.size() && to >= 0 && to < nodes.size()) {
            Node n1 = nodes.get(from);
            Node n2 = nodes.get(to);
            
            if (!n1.neighbors.contains(n2)) {
                n1.neighbors.add(n2);
                n2.neighbors.add(n1);
                edges.add(new Edge(n1, n2));
            }
        }
    }
    
    void setStart(int id) {
        startNodeId = id;
    }
    
    void setGoal(int id) {
        goalNodeId = id;
    }
    
    Node getStartNode() {
        if (startNodeId >= 0 && startNodeId < nodes.size()) {
            return nodes.get(startNodeId);
        }
        return null;
    }
    
    Node getGoalNode() {
        if (goalNodeId >= 0 && goalNodeId < nodes.size()) {
            return nodes.get(goalNodeId);
        }
        return null;
    }
    
    void generateGridMaze(int cols, int rows, int cellSize) {
        clear();
        
        this.mazeCols = cols;
        this.mazeRows = rows;
        
        for (int r = 0; r < rows; r++) {
            for (int c = 0; c < cols; c++) {
                float x = c * cellSize + cellSize/2;
                float y = r * cellSize + cellSize/2;
                addNode(x, y);
            }
        }
        
        boolean[] visited = new boolean[nodes.size()];
        carveMaze(0, cols, rows, visited); 
        
        int extraPaths = cols * rows / 12;
        for (int i = 0; i < extraPaths; i++) {
            int n1 = (int)random(nodes.size());
            int n2 = getRandomNeighborIndex(n1, cols, rows);
            if (n2 >= 0) {
                addEdge(n1, n2);
            }
        }
    }
    
    void carveMaze(int current, int cols, int rows, boolean[] visited) {
        visited[current] = true;
        
        ArrayList<Integer> neighbors = new ArrayList<Integer>();
        int row = current / cols;
        int col = current % cols;
        
        if (row > 0) neighbors.add(current - cols); 
        if (row < rows - 1) neighbors.add(current + cols); 
        if (col > 0) neighbors.add(current - 1); 
        if (col < cols - 1) neighbors.add(current + 1); 
        
        for (int i = neighbors.size() - 1; i > 0; i--) {
            int j = (int)random(i + 1);
            int temp = neighbors.get(i);
            neighbors.set(i, neighbors.get(j));
            neighbors.set(j, temp);
        }
        
        // 재귀적으로 방문
        for (int next : neighbors) {
            if (!visited[next]) {
                addEdge(current, next);
                carveMaze(next, cols, rows, visited);
            }
        }
    }
    
    int getRandomNeighborIndex(int nodeId, int cols, int rows) {
        int row = nodeId / cols;
        int col = nodeId % cols;
        
        ArrayList<Integer> candidates = new ArrayList<Integer>();
        if (row > 0) candidates.add(nodeId - cols);
        if (row < rows - 1) candidates.add(nodeId + cols);
        if (col > 0) candidates.add(nodeId - 1);
        if (col < cols - 1) candidates.add(nodeId + 1);
        
        if (candidates.size() > 0) {
            return candidates.get((int)random(candidates.size()));
        }
        return -1;
    }
    
    void render() {
        renderMazeWalls(); 
        
        for (Edge e : edges) {
            e.render();
        }
        
        for (Node n : nodes) {
            n.render();
        }
    }
    
    void renderMazeWalls() {
        if (nodes.isEmpty() || mazeCols == 0 || mazeRows == 0) return;
        
        stroke(100, 100, 150);
        strokeWeight(3);
        
        for (int i = 0; i < nodes.size(); i++) {
            Node current = nodes.get(i);
            PVector pos = current.pos;
            int row = i / mazeCols;
            int col = i % mazeCols;
            
            if (col < mazeCols - 1) {
                Node right = nodes.get(i + 1);
                if (!current.neighbors.contains(right)) {
                    line(pos.x + gridSize/2, pos.y - gridSize/2, 
                         pos.x + gridSize/2, pos.y + gridSize/2);
                }
            }
            
            if (row < mazeRows - 1) {
                Node down = nodes.get(i + mazeCols);
                if (!current.neighbors.contains(down)) {
                    line(pos.x - gridSize/2, pos.y + gridSize/2, 
                         pos.x + gridSize/2, pos.y + gridSize/2);
                }
            }
            
            if (row == 0) {
                if (i != startNodeId) {
                    line(pos.x - gridSize/2, pos.y - gridSize/2, 
                         pos.x + gridSize/2, pos.y - gridSize/2);
                }
            }
            if (col == 0) {
                if (i != startNodeId) {
                    line(pos.x - gridSize/2, pos.y - gridSize/2, 
                         pos.x - gridSize/2, pos.y + gridSize/2);
                }
            }
            if (col == mazeCols - 1) {
                if (i != goalNodeId) {
                    line(pos.x + gridSize/2, pos.y - gridSize/2, 
                         pos.x + gridSize/2, pos.y + gridSize/2);
                }
            }
            if (row == mazeRows - 1) {
                 if (i != goalNodeId) {
                    line(pos.x - gridSize/2, pos.y + gridSize/2, 
                         pos.x + gridSize/2, pos.y + gridSize/2);
                 }
            }
        }
    }
}

class Node {
    int id;
    PVector pos;
    ArrayList<Node> neighbors;
    boolean visited;
    int visitOrder;
    boolean onSuccessPath;
    
    Node(int id, float x, float y) {
        this.id = id;
        this.pos = new PVector(x, y);
        this.neighbors = new ArrayList<Node>();
        this.visited = false;
        this.visitOrder = -1;
        this.onSuccessPath = false;
    }
    
    void render() {
        if (id == graph.startNodeId) {
            fill(150, 255, 150); 
            stroke(200, 255, 200);
        } else if (id == graph.goalNodeId) {
            fill(255, 150, 150); 
        } else if (onSuccessPath) {
            fill(255, 215, 0);
            stroke(255, 255, 100);
        } else if (visited) {
            fill(60, 60, 90); 
            stroke(90, 90, 120);
        } else {
            fill(30, 30, 45); 
            stroke(60, 60, 80);
        }
        
        strokeWeight(1);
        circle(pos.x, pos.y, nodeRadius * 2);
        
        if (ui.showVisitOrder && visitOrder >= 0) {
            fill(255);
            textAlign(CENTER, CENTER);
            textSize(8);
            text(visitOrder, pos.x, pos.y + 1);
        }
    }
}

class Edge {
    Node from;
    Node to;
    
    Edge(Node from, Node to) {
        this.from = from;
        this.to = to;
    }
    
    void render() {
        if (from.onSuccessPath && to.onSuccessPath) {
            stroke(255, 215, 0, 250); 
            strokeWeight(5);
        } else if (from.visited && to.visited) {
             stroke(80, 80, 100, 200); 
             strokeWeight(3);
        } else {
             stroke(80, 80, 100); 
             strokeWeight(3);
        }
        
        line(from.pos.x, from.pos.y, to.pos.x, to.pos.y);
    }
}
