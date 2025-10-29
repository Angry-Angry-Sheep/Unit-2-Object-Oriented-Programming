final int INTRO = 0;
final int GAME = 1;
final int PAUSE = 2;
final int GAMEOVER_WIN = 3;
final int GAMEOVER_LOSE = 4;
int mode = INTRO;

PFont defaultFont;

ArrayList<Asteroid> asteroids = new ArrayList<Asteroid>();
ArrayList<Bullet> bullets = new ArrayList<Bullet>();
ArrayList<Particles> particles = new ArrayList<Particles>();
int lives = 3;
int score = 0;

boolean firing = false;
int lastShotTime = 0;
int fireDelay = 50; 

Player player;

void setup() {
  size(1000, 800);
  defaultFont = createFont("SansSerif", 24);
  textFont(defaultFont);
  resetGame();
}

void draw() {
  switch(mode) {
    case INTRO: intro(); break;
    case GAME: game(); break;
    case PAUSE: pause(); break;
    case GAMEOVER_WIN: gameoverWin(); break;
    case GAMEOVER_LOSE: gameoverLose(); break;
  }
}

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

void game() {
  // Continuous firing logic
  if (firing && millis() - lastShotTime > fireDelay) {
    player.shoot();
    //player.shoot(player.angle-(HALF_PI/8));
    //player.shoot(player.angle+(HALF_PI/8));
    //player.shoot(player.angle-(HALF_PI/16));
    //player.shoot(player.angle+(HALF_PI/16));
    lastShotTime = millis();
  }

  background(10, 10, 20);

  player.update();
  player.show();

  for (Bullet b : bullets) {
    b.update();
    b.show();
  }

  for (Asteroid a : asteroids) {
    a.update();
    a.show();
  }
  
  for (Particles p : particles) {
    p.update();
    p.show();
  }
  
  for (Asteroid a : asteroids) {
  handlePlayerAsteroidCollision(player, a);
  }

  // collisions
  ArrayList<Asteroid> newAsteroids = new ArrayList<Asteroid>();

  for (Bullet b : bullets) {
    if (!b.alive) continue;

    for (Asteroid a : asteroids) {
      if (!a.alive) continue;

        if (dist(b.pos.x, b.pos.y, a.pos.x, a.pos.y) < a.getRadius()) {
          a.hp -= 1;
          b.alive = false;
          
          if (a.hp <=0) {
          a.alive = false;
          score += 10;
  
          // Split with spread
          if (a.size > 0) {
            if (a.size == 2)
              splitAstroid(3, a, newAsteroids);
            else
              splitAstroid(2, a, newAsteroids);
          }
        }
      }
    }
  }

  // cleanup
  bullets.removeIf(b -> !b.alive);
  asteroids.removeIf(a -> !a.alive);
  asteroids.addAll(newAsteroids);

  // HUD
  fill(255);
  textAlign(LEFT);
  textSize(20);
  text("Lives: " + lives, 20, 30);
  text("Asteroids: " + asteroids.size(), 20, 55);
  text("Score: " + score, 20, 80);

  // Win/lose
  if (lives <= 0) mode = GAMEOVER_LOSE;
  if (asteroids.isEmpty()) mode = GAMEOVER_WIN;
}

void splitAstroid(int num, Asteroid a, ArrayList<Asteroid> newAsteroids) {
  for (int i = 0; i < num; i++) {
    Asteroid small = new Asteroid(a.size - 1);
    small.pos = a.pos.copy();
    float spreadAngle = random(TWO_PI);  // random direction
    small.vel = PVector.fromAngle(spreadAngle).mult(random(2, 3)); //scatter sub astroids
    newAsteroids.add(small);
  }
}

// PAUSE MODE
void pause() {
  player.show();

  for (Bullet b : bullets) {
    b.show();
  }

  for (Asteroid a : asteroids) {
    a.show();
  }
  
  for (Particles p : particles) {
    p.show();
  }
  fill(0, 150);
  rect(0, 0, width, height);
  fill(255);
  textAlign(CENTER);
  textSize(48);
  text("PAUSED", width/2, height/2);
  textSize(24);
  text("Press P to Resume", width/2, height/2 + 60);
}

// win
void gameoverWin() {
  background(0);
  fill(150, 255, 200);
  textAlign(CENTER);
  textSize(48);
  text("YOU WIN!", width/2, height/2);
  textSize(24);
  text("Press R to Restart", width/2, height/2 + 80);
}

// lose
void gameoverLose() {
  background(0);
  fill(255, 80, 80);
  textAlign(CENTER);
  textSize(48);
  text("GAME OVER", width/2, height/2);
  textSize(24);
  text("Press R to Retry", width/2, height/2 + 80);
}

void keyPressed() {
  if (mode == INTRO && key == ENTER) mode = GAME;
  else if (mode == GAME && key == 'p') mode = PAUSE;
  else if (mode == PAUSE && key == 'p') mode = GAME;
  else if ((mode == GAMEOVER_WIN || mode == GAMEOVER_LOSE) && (key == 'r' || key == 'R')) {
    resetGame();
    mode = INTRO;
  }
  else if (mode == GAME) {
    player.keyPressed();
    if (key == ' ' || key == 'z') firing = true; // start continuous fire
  }
}

void keyReleased() {
  if (mode == GAME) {
    player.keyReleased();
    if (key == ' ' || key == 'z') firing = false; // stop continuous fire
  }
}

void resetGame() {
  lives = 3;
  score = 0;
  asteroids.clear();
  bullets.clear();
  for (int i = 0; i < 7; i++) asteroids.add(new Asteroid(2));
  player = new Player(width/2, height/2);
}

//bounce when plaeyer hits astroid
void handlePlayerAsteroidCollision(Player p, Asteroid a) {
  float playerRadius = 12;
  float asteroidRadius = a.getRadius();
  float dist = PVector.dist(p.pos, a.pos);
  float minDist = playerRadius + asteroidRadius;

  if (dist < minDist) {
    PVector normal = PVector.sub(a.pos, p.pos).normalize();

    float overlap = minDist - dist;
    p.pos.add(PVector.mult(normal, -overlap * 0.8));
    a.pos.add(PVector.mult(normal, overlap * 0.2));

    PVector relativeVel = PVector.sub(p.vel, a.vel);
    float velAlongNormal = PVector.dot(relativeVel, normal);

    float restitution = 2.2;
    float playerMass = 1;
    float asteroidMass = 10;
    if (a.size == 1)
      asteroidMass = 5;
    if (a.size == 0)
      asteroidMass = 2;
    float totalMass = playerMass + asteroidMass;

    float impulse = -(1 + restitution) * velAlongNormal / totalMass;

    float minImpulse = 0;
    if (abs(impulse) < minImpulse) impulse = (impulse < 0 ? -1 : 1) * minImpulse;

    PVector impulseVec = PVector.mult(normal, impulse);

    p.vel.add(PVector.mult(impulseVec, asteroidMass * 2.0));  
    a.vel.sub(PVector.mult(impulseVec, playerMass * 0.4));

    a.spin += random(-0.05, 0.05);
    a.vel.add(PVector.random2D().mult(0.6));
    p.vel.mult(1.4);  // speed amplification
  }
}
