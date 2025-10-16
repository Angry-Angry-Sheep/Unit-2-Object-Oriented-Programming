class Player {
  PVector pos, vel;
  float angle;                     
  float thrustPower = 0.1;  
  float rotationSpeed = 0.055; 
  float damping = 1; 
  float speedLimit = 6;
  float wrapMargin = 20;
  boolean upPressed, downPressed, leftPressed, rightPressed;

  Player(float x, float y) {
    pos = new PVector(x, y);
    vel = new PVector(0, 0);
    angle = -HALF_PI;
  }

  void update() {
    if (leftPressed)  angle -= rotationSpeed;
    if (rightPressed) angle += rotationSpeed;

    if (upPressed) {
      PVector force = PVector.fromAngle(angle);
      force.mult(thrustPower);
      vel.add(force);
    }
    if (downPressed) {
      PVector force = PVector.fromAngle(angle);
      force.mult(-thrustPower * 0.6);
      vel.add(force);
    }

    vel.mult(damping);

    // max speed
    if (vel.mag() > speedLimit) vel.setMag(speedLimit);

    pos.add(vel);
    wrap();
  }

  void show() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle + HALF_PI);
    noFill();
    stroke(255, 255, 0);
    strokeWeight(2);
    triangle(-10, 10, 10, 10, 0, -15);
    popMatrix();
  }

  void wrap() {
    if (pos.x < -wrapMargin) pos.x = width + wrapMargin;
    if (pos.x > width + wrapMargin) pos.x = -wrapMargin;
    if (pos.y < -wrapMargin) pos.y = height + wrapMargin;
    if (pos.y > height + wrapMargin) pos.y = -wrapMargin;
  }

  void keyPressed() {
    if (keyCode == UP) upPressed = true;
    //if (keyCode == DOWN) downPressed = true; unused for now since no decelleration
    if (keyCode == LEFT) leftPressed = true;
    if (keyCode == RIGHT) rightPressed = true;
  }

  void keyReleased() {
    if (keyCode == UP) upPressed = false;
    //if (keyCode == DOWN) downPressed = false;
    if (keyCode == LEFT) leftPressed = false;
    if (keyCode == RIGHT) rightPressed = false;
  }
}
