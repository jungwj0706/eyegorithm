class ParticleSystem {
  ArrayList<Particle> particles;
  
  ParticleSystem() {
    particles = new ArrayList<Particle>();
  }
  
  void add(Particle p) {
    particles.add(p);
  }
  
  void update() {
    ArrayList<Particle> dead = new ArrayList<Particle>();
    
    for (Particle p : particles) {
      p.update();
      if (p.isDead()) {
        dead.add(p);
      }
    }
    
    particles.removeAll(dead);
  }
  
  void render() {
    for (Particle p : particles) {
      p.render();
    }
  }
  
  void clear() {
    particles.clear();
  }
}

class Particle {
  PVector pos;
  PVector vel;
  color col;
  int life;
  int maxLife;
  
  Particle(PVector pos, PVector vel, color col, int maxLife) {
    this.pos = pos.copy();
    this.vel = vel.copy();
    this.col = col;
    this.life = maxLife;
    this.maxLife = maxLife;
  }
  
  void update() {
    pos.add(vel);
    vel.mult(0.95);
    life--;
  }
  
  boolean isDead() {
    return life <= 0;
  }
  
  void render() {
    float alpha = map(life, 0, maxLife, 0, 255);
    fill(col, alpha);
    noStroke();
    circle(pos.x, pos.y, 4);
  }
}
