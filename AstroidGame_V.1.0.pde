// =====================================================
// 🚀 ASTEROID BLASTER — Mode Framework + Stable Asteroids
// =====================================================

final int INTRO = 0;
final int GAME = 1;
final int PAUSE = 2;
final int GAMEOVER_WIN = 3;
final int GAMEOVER_LOSE = 4;
int mode = INTRO;

PFont defaultFont;

ArrayList<Asteroid> asteroids = new ArrayList<Asteroid>();
int lives = 3;
int score = 0;

// =====================================================
void setup() {
  size(800, 600);
  defaultFont = createFont("SansSerif", 24);
  textFont(defaultFont);
  resetGame();
}

// =====================================================
void draw() {
  switch(mode) {
    case INTRO: intro(); break;
    case GAME: game(); break;
    case PAUSE: pause(); break;
    case GAMEOVER_WIN: gameoverWin(); break;
    case GAMEOVER_LOSE: gameoverLose(); break;
  }
}

// =====================================================
// INTRO MODE
void intro() {
  background(0);
  fill(255);
  textAlign(CENTER);
  textSize(48);
  text("ASTEROID BLASTER", width/2, height/2 - 100);
  textSize(24);
  text("Press ENTER to Start", width/2, height/2 + 50);
}

// GAME MODE
void game() {
  background(10, 10, 20);
  
  // Render stuff
  for (Asteroid a : asteroids) {
    a.update();
    a.show();
  }
  asteroids.removeIf(a -> !a.alive);

  // HUD
  fill(255);
  textAlign(LEFT);
  textSize(20);
  text("Lives: " + lives, 20, 30);
  text("Asteroids: " + asteroids.size(), 20, 55);
  text("Score: " + score, 20, 80);

  // Win conditions
  if (lives <= 0) mode = GAMEOVER_LOSE;
  if (asteroids.isEmpty()) mode = GAMEOVER_WIN;
}

// PAUSE MODE
void pause() {
  fill(0, 150);
  rect(0, 0, width, height);
  fill(255);
  textAlign(CENTER);
  textSize(48);
  text("PAUSED", width/2, height/2);
  textSize(24);
  text("Press P to Resume", width/2, height/2 + 60);
}

// GAMEOVER WIN MODE
void gameoverWin() {
  background(0);
  fill(150, 255, 200);
  textAlign(CENTER);
  textSize(48);
  text("YOU WIN!", width/2, height/2);
  textSize(24);
  text("Press R to Restart", width/2, height/2 + 80);
}

// GAMEOVER LOSE MODE
void gameoverLose() {
  background(0);
  fill(255, 80, 80);
  textAlign(CENTER);
  textSize(48);
  text("GAME OVER", width/2, height/2);
  textSize(24);
  text("Press R to Retry", width/2, height/2 + 80);
}

// KEY CONTROLS
void keyPressed() {
  if (mode == INTRO && key == ENTER) mode = GAME;
  else if (mode == GAME && key == 'p') mode = PAUSE;
  else if (mode == PAUSE && key == 'p') mode = GAME;
  else if ((mode == GAMEOVER_WIN || mode == GAMEOVER_LOSE) && (key == 'r' || key == 'R')) {
    resetGame();
    mode = INTRO;
  }
}

// RESET GAME
void resetGame() {
  lives = 3;
  score = 0;
  asteroids.clear();
  for (int i = 0; i < 5; i++) asteroids.add(new Asteroid(2)); // 2 = big
}

// ASTEROID CLASS
class Asteroid {
  PVector pos, vel;
  float size;  // 2 = big, 1 = medium, 0 = small
  float angle, spin;
  boolean alive = true;
  PVector[] shape;  // fixed shape so it doesn't jitter
  
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
    // remove the astroid
    if (pos.x < -r) pos.x = width + r;
    if (pos.x > width + r) pos.x = -r;
    if (pos.y < -r) pos.y = height + r;
    if (pos.y > height + r) pos.y = -r;
  }

  float getRadius() {
    return size == 2 ? 60 : size == 1 ? 30 : 15;
  }
}

// =====================================================
// SPLITTING LOGIC
void splitAsteroid(Asteroid a) {
  if (a.size > 0) { // not smalle
    for (int i = 0; i < 2; i++) {
      Asteroid newA = new Asteroid(a.size - 1);
      newA.pos = a.pos.copy();
      asteroids.add(newA);
    }
  }
  a.alive = false;
}
