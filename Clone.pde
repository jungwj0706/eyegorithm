class Clone {
    Node current;
    Node target;
    Clone parent;
    ArrayList<Node> path;
    int depth;
    boolean alive;
    boolean isMoving;
    float moveProgress;
    int fadeAlpha;
    
    boolean isSplitting;
    Node returnPath;

    Clone(Node start, Clone parent, int depth) {
        this.current = start;
        this.target = null;
        this.parent = parent;
        this.path = new ArrayList<Node>();
        this.path.add(start);
        this.depth = depth;
        this.alive = true;
        this.isMoving = false;
        this.isSplitting = false; 
        this.returnPath = null; 
        this.moveProgress = 0;
        this.fadeAlpha = 255;
    }
    
    void setReturnPath(Node node) {
        this.returnPath = node;
    }

    color getDepthColor() {
        if (ui.colorByDepth) {
            float hue = (depth * 30) % 360;
            colorMode(HSB, 360, 100, 100);
            color c = color(hue, 80, 90);
            colorMode(RGB, 255, 255, 255);
            return c;
        } else {
            return color(100, 150, 255);
        }
    }

    void render() {
        PVector pos;

        if (isMoving && target != null) {
            pos = PVector.lerp(current.pos, target.pos, moveProgress);
        } else {
            pos = current.pos.copy();
        }

        int alpha = alive ? 255 : fadeAlpha;
        
        if (isSplitting && alive) {
            fill(getDepthColor(), alpha);
            stroke(255, 255, 150, alpha);
            strokeWeight(3);
            circle(pos.x, pos.y, 14);
        } else {
            fill(getDepthColor(), alpha);
            stroke(255, alpha);
            strokeWeight(2);
            circle(pos.x, pos.y, 12);
        }

        fill(255, alpha);
        noStroke();
        circle(pos.x - 2, pos.y - 1, 2);
        circle(pos.x + 2, pos.y - 1, 2);
    }
}
