class Bullet {
  PVector pos, vel;
  float speed = 10;
  float lifespan = 90000000;
  boolean alive = true;
  boolean wrapAround = false;
  boolean bulletType;
  
  Bullet(float x, float y, float angle, boolean type) {
    pos = new PVector(x, y);
    vel = PVector.fromAngle(angle).mult(speed);
    bulletType = type;
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
    if (bulletType)
      stroke(255, 255, 120);
    else
      stroke(255, 120, 120);
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
