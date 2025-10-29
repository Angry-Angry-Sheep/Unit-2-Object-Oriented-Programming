class Bullet {
  PVector pos, vel;
  float speed = 10;
  float lifespan = 90000000;
  boolean alive = true;
  boolean wrapAround = false;
  
  Bullet(float x, float y, float angle) {
    pos = new PVector(x, y);
    vel = PVector.fromAngle(angle).mult(speed);
  }

  void update() {
    pos.add(vel);
    lifespan--;
    if (lifespan <= 0) alive = false;
    wrap();
  }

  void show() {
    pushMatrix();
    translate(pos.x, pos.y);
    stroke(255, 255, 120);
    strokeWeight(4);
    point(0, 0);
    popMatrix();
  }

  void wrap() {
    if (wrapAround) {
      if (pos.x < 0) pos.x = width;
      if (pos.x > width) pos.x = 0;
      if (pos.y < 0) pos.y = height;
      if (pos.y > height) pos.y = 0;
    }
    else {
      if (pos.x < 0) alive = false;
      if (pos.x > width) alive = false;
      if (pos.y < 0) alive = false;
      if (pos.y > height) alive = false;
    }
  }
}
