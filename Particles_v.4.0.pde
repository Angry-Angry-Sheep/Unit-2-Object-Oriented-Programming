class Particles {
  PVector pos, vel;
  float speed = 3;
  float lifespan = 255; 
  boolean alive = true;
  
  color col;  // particle color
  
  Particles(float x, float y, float angle) {
    pos = new PVector(x, y);
    
    float spread = radians(20);
    float randomAngle = angle + random(-spread, spread);
    
    vel = PVector.fromAngle(randomAngle).mult(speed * random(0.8, 1.2));
    
    float t = random(1);
    col = lerpColor(color(255, 255, 0), color(255, 0, 0), t);
  }
  
  void update() {
    pos.add(vel);
    
    lifespan -= 2;
    if (lifespan <= 0) alive = false;
    
    wrap();
  }
  
  void show() {
    pushMatrix();
    translate(pos.x, pos.y);
    
    stroke(red(col), green(col), blue(col), lifespan);
    strokeWeight(4);
    point(0, 0);
    
    popMatrix();
  }
  
  void wrap() {
    if (pos.x < 0) pos.x = width;
    if (pos.x > width) pos.x = 0;
    if (pos.y < 0) pos.y = height;
    if (pos.y > height) pos.y = 0;
  }
}
