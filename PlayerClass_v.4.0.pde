class Player {
  PVector pos, vel;
  float angle;                     
  float thrustPower = 0.1;  
  float rotationSpeed = 0.055; 
  float damping = 0.99; 
  float speedLimit = 5;
  float wrapMargin = 20;
  boolean upPressed, downPressed, leftPressed, rightPressed;
  boolean playerType;
  float maxHealth = 100;
  float health = 100;
  int timer = 0;

  Player(float x, float y, boolean type) {
    pos = new PVector(x, y);
    vel = new PVector(0, 0);
    angle = -HALF_PI;
    playerType = type;
  }


  void update() {
    timer++;
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
    
    if (upPressed) {
      particles.add(new Particles(pos.x-cos(angle)*6, pos.y-sin(angle)*6, angle + PI));
    }
    if (downPressed) {
      if (timer%2==0) {
        particles.add(new Particles(pos.x-cos(angle)*6, pos.y-sin(angle)*6, angle + PI/3));
        particles.add(new Particles(pos.x-cos(angle)*6, pos.y-sin(angle)*6, angle - PI/3));
      }
    }
  }

  void show() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle + HALF_PI);
    noFill();
    if (playerType)
      stroke(255, 255, 0);
    else
      stroke(255, 0, 0);
    strokeWeight(2);
    triangle(-12, 12, 12, 12, 0, -16);
    popMatrix();
  }

  void wrap() {
    if (pos.x < -wrapMargin) pos.x = width + wrapMargin;
    if (pos.x > width + wrapMargin) pos.x = -wrapMargin;
    if (pos.y < -wrapMargin) pos.y = height + wrapMargin;
    if (pos.y > height + wrapMargin) pos.y = -wrapMargin;
  }

  void keyPressed() {
    if (playerType) {
      if (keyCode == UP) upPressed = true;
      if (keyCode == DOWN) downPressed = true;
      if (keyCode == LEFT) leftPressed = true;
      if (keyCode == RIGHT) rightPressed = true;
    }
    else {
      if (keyCode == 'W' || keyCode == 'w') upPressed = true;
      if (keyCode == 'S' || keyCode == 's') downPressed = true;
      if (keyCode == 'A' || keyCode == 'a') leftPressed = true;
      if (keyCode == 'D' || keyCode == 'd') rightPressed = true;
    }
  }

  void keyReleased() {
    if (playerType) {
      if (keyCode == UP) upPressed = false;
      if (keyCode == DOWN) downPressed = false;
      if (keyCode == LEFT) leftPressed = false;
      if (keyCode == RIGHT) rightPressed = false;
    }
    else {
      if (keyCode == 'W' || keyCode == 'w') upPressed = false;
      if (keyCode == 'S' || keyCode == 's') downPressed = false;
      if (keyCode == 'A' || keyCode == 'a') leftPressed = false;
      if (keyCode == 'D' || keyCode == 'd') rightPressed = false;
    }
  }
  void shoot(float a, boolean type) {
    PVector dir = PVector.fromAngle(angle);
    PVector bulletPos = pos.copy().add(dir.mult(15));
    bullets.add(new Bullet(bulletPos.x, bulletPos.y, a, type));
  }
  void shoot(boolean type) {
    PVector dir = PVector.fromAngle(angle);
    PVector bulletPos = pos.copy().add(dir.mult(15));
    bullets.add(new Bullet(bulletPos.x, bulletPos.y, angle, type));
  }

}
