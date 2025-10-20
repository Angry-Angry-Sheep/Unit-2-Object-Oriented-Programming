class Asteroid {
  PVector pos, vel;
  float size;  // 2 = big 1 = medium 0 = small?
  float angle, spin;
  boolean alive = true;
  PVector[] shape;
  
  Asteroid(float s) {
    size = s;
    pos = new PVector(random(width), random(height));
    vel = PVector.random2D().mult(random(1, 2));
    angle = random(TWO_PI);
    spin = random(-0.03, 0.03);
    
    // Create a unique but fixed shape once
    shape = new PVector[8];
    for (int i = 0; i < shape.length; i++) {
      float r = getRadius() + random(-5, 5);
      float x = cos(TWO_PI/shape.length * i) * r;
      float y = sin(TWO_PI/shape.length * i) * r;
      shape[i] = new PVector(x, y);
    }
  }

  void update() {
    pos.add(vel);
    angle += spin;
    wrap();
  }

  void show() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle);
    noFill();
    stroke(200, 230, 255);
    strokeWeight(2);
    beginShape();
    for (int i = 0; i < shape.length; i++) {
      vertex(shape[i].x, shape[i].y);
    }
    endShape(CLOSE);
    popMatrix();
  }

  void wrap() {
    float r = getRadius();
    // delete destroy
    if (pos.x < -r) pos.x = width + r;
    if (pos.x > width + r) pos.x = -r;
    if (pos.y < -r) pos.y = height + r;
    if (pos.y > height + r) pos.y = -r;
  }

  float getRadius() {
    return size == 2 ? 60 : size == 1 ? 30 : 15;
  }
}

void splitAsteroid(Asteroid a) {
  if (a.size > 0) {
    for (int i = 0; i < 2; i++) {
      Asteroid newA = new Asteroid(a.size - 1);
      newA.pos = a.pos.copy();
      asteroids.add(newA);
    }
  }
  a.alive = false;
}
