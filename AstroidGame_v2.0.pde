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

Player player;

void setup() {
  size(800, 600);
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
  background(10, 10, 20);
  
  player.update();
  player.show();
  
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
  }
}

void keyReleased() {
  if (mode == GAME) {
    player.keyReleased();
  }
}


// RESET GAME
void resetGame() {
  player = new Player(width/2, height/2);
  lives = 3;
  score = 0;
  asteroids.clear();
  for (int i = 0; i < 5; i++) asteroids.add(new Asteroid(2)); // 2 is the big astroid
}
