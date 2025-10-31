final int INTRO = 0;
final int GAME = 1;
final int PAUSE = 2;
final int GAMEOVER_WIN = 3;
final int GAMEOVER_LOSE_PLAYER_1 = 4;
final int GAMEOVER_LOSE_PLAYER_2 = 5;
int mode = INTRO;

PFont defaultFont;

ArrayList<Asteroid> asteroids = new ArrayList<Asteroid>();
ArrayList<Bullet> bullets = new ArrayList<Bullet>();
ArrayList<Particles> particles = new ArrayList<Particles>();
int score = 0;

boolean firing1 = false;
int lastShotTime1 = 0;
boolean firing2 = false;
int lastShotTime2 = 0;
int fireDelay = 50; 

Player player1;
Player player2;

void setup() {
  size(1400, 830);
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
    case GAMEOVER_LOSE_PLAYER_1: gameoverLose(true); break;
    case GAMEOVER_LOSE_PLAYER_2: gameoverLose(false); break;
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
  if (firing1 && millis() - lastShotTime1 > fireDelay) {
    player1.shoot(true);
    lastShotTime1 = millis();
  }
  
  if (firing2 && millis() - lastShotTime2 > fireDelay) {
    player2.shoot(false);
    lastShotTime2 = millis();
  }

  background(10, 10, 20);

  player1.update();
  player1.show();
  player2.update();
  player2.show();

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
  handlePlayerAsteroidCollision(player1, a);
  handlePlayerAsteroidCollision(player2, a);
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
  
  // Bullet vs Player collisions
  for (Bullet b : bullets) {
    if (!b.alive) continue;
  
    // Bullet from player 1 hits player 2
    if (b.bulletType == true) {
      float d = dist(b.pos.x, b.pos.y, player2.pos.x, player2.pos.y);
      if (d < 35) { // collision radius (adjust for size)
        player2.health -= 2;
        b.alive = false;
      }
    }
  
    // Bullet from player 2 hits player 1
    else {
      float d = dist(b.pos.x, b.pos.y, player1.pos.x, player1.pos.y);
      if (d < 35) {
        player1.health -= 2;
        b.alive = false;
      }
    }
  }

  // cleanup
  bullets.removeIf(b -> !b.alive);
  asteroids.removeIf(a -> !a.alive);
  asteroids.addAll(newAsteroids);
  
  bullets.removeIf(b -> !b.alive);
  if (bullets.size() > 200) bullets.subList(0, bullets.size()-200).clear();
  
  particles.removeIf(p -> !p.alive);
  if (particles.size() > 400) particles.subList(0, particles.size()-400).clear();
  
  // Health Bars
  int barWidth = 200;
  int barHeight = 20;
  
  // Player 1 health bar right
  stroke(255,255,255);
  fill(80);
  rect(width - barWidth - 20, height - 40, barWidth, barHeight);
  fill(0, 255, 0);  // constant green
  rect(width - barWidth - 20, height - 40, map(player1.health, 0, player1.maxHealth, 0, barWidth), barHeight);
  fill(255);
  text("P1 HP", 20, height - 50);
  
  // Player 2 health bar (left)
  fill(80);
  rect(20, height - 40, barWidth, barHeight);
  fill(0, 255, 0);  // constant green
  rect(20, height - 40, map(player2.health, 0, player2.maxHealth, 0, barWidth), barHeight);
  fill(255);
  textAlign(RIGHT);
  text("P2 HP", width - 20, height - 50);
  textAlign(LEFT);
  
  // Win/lose
  if (player1.health <= 0) {
    mode = GAMEOVER_LOSE_PLAYER_1;
    println("Player 1 lost!");
  } 
  else if (player2.health <= 0) {
    mode = GAMEOVER_LOSE_PLAYER_2;
    println("Player 2 lost!");
  }

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
  player1.show();
  player2.show();

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
void gameoverLose(boolean type) {
  background(0);
  if (type)
    fill(255, 80, 80);
  else
    fill(255, 255, 0);
  textAlign(CENTER);
  textSize(48);
  if (type)
    text("PLAYER RED WINS", width/2, height/2);
  else
    text("PLAYER YELLOW WINS", width/2, height/2);
  textSize(24);
  text("Press R to Retry", width/2, height/2 + 80);
}

void keyPressed() {
  if (mode == INTRO && key == ENTER) mode = GAME;
  else if (mode == GAME && key == 'p') mode = PAUSE;
  else if (mode == PAUSE && key == 'p') mode = GAME;
  else if ((mode == GAMEOVER_WIN || mode == GAMEOVER_LOSE_PLAYER_1 || mode == GAMEOVER_LOSE_PLAYER_2) && (key == 'r' || key == 'R')) {
    resetGame();
    mode = INTRO;
  }
  else if (mode == GAME) {
    player1.keyPressed();
    player2.keyPressed();
    if (key == ' ') firing1 = true; // start continuous fire
    if (key == 'e' || key == 'E' || key == '\\' || key == '|') firing2 =true;
  }
}

void keyReleased() {
  if (mode == GAME) {
    player1.keyReleased();
    player2.keyReleased();
    if (key == ' ') firing1 = false; // start continuous fire
    if (key == 'e' || key == 'E' || key == '\\' || key == '|') firing2 = false; // start continuous fire
  }
}

void resetGame() {
  score = 0;
  asteroids.clear();
  bullets.clear();
  for (int i = 0; i < 7; i++) asteroids.add(new Asteroid(2));
  player1 = new Player(width*3/4, height/2, true);
  player2 = new Player(width/4, height/2, false);
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

    float restitution = 1.2;
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

    p.vel.add(PVector.mult(impulseVec, asteroidMass * 1.0));  
    a.vel.sub(PVector.mult(impulseVec, playerMass * 0.2));

    a.spin += random(-0.05, 0.05);
    a.vel.add(PVector.random2D().mult(0.6));
    p.vel.mult(1.4);  // speed amplification
  }
}
