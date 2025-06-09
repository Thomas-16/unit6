import fisica.*;

// TODOS:
// SPIKES
// GRAVITY FLIPPING

// colors
color TRANSPARENT = color(0,0,0,0);
color GROUND = #2f3699;

PImage mapImg;
PImage playerImg;
PImage backgroundImg;
PImage groundTileImg;

FPlayer player;
FWorld world;
FTile[][] tiles;
ArrayList<FTile> groundTiles = new ArrayList<FTile>();

final float groundY = 900;
int groundStartIdx = 0;               
int groundVisibleCount;

float bgOffset = 0;
float bgScrollSpeed = 1.4;

int normalGravityStrength = 3400;
int fallingGravityStrength = 5300;
int worldMovingSpeed = 8;

float worldOffset;

// input
boolean spaceKeyDown;

final int tileSize = 60;
final int groundTileSize = 60*4;

void setup() {
  size(1800, 1000, P2D);
  frameRate(60);
  Fisica.init(this);
  
  world = new FWorld();
  world.setGravity(0, normalGravityStrength);
  world.setGrabbable(false);
  world.setEdges();
  
  mapImg = loadImage("map.png");
  playerImg = scaleImage(loadImage("player.png"), tileSize, tileSize);
  backgroundImg = scaleImage(loadImage("background.png"), width, height);
  groundTileImg = scaleImage(loadImage("groundTile.png"), 4*tileSize, 4*tileSize);
  
  tiles = new FTile[mapImg.width][mapImg.height];
  
  groundVisibleCount = ceil(width / (float)groundTileSize) + 1;

  for (int i = 0; i < groundVisibleCount; i++) {
    FTile g = new FTile(groundTileSize);
    g.attachImage(groundTileImg);
    g.setPosition(i*groundTileSize + groundTileSize/2, groundY);
    world.add(g);
    groundTiles.add(g);
  }
  
  player = new FPlayer(400, 12*60, tileSize, tileSize, playerImg);
  world.add(player);
}

void draw() {
  image(backgroundImg, -bgOffset, 0);
  image(backgroundImg, width - bgOffset, 0);
  
  bgOffset += bgScrollSpeed;
  if (bgOffset >= width) bgOffset -= width;
  
  //pushMatrix();
  //scale(0.5);
  //translate(width/2, height/2);
  handleGravity();
  updateObjects();
  
  worldOffset -= worldMovingSpeed;
  updateTiles();
  updateGround();
  
  world.step();
  world.draw();
  //world.drawDebug();
  //world.drawDebugData();
  //popMatrix();
}

void updateTiles() {
  for (int x = 0; x < tiles.length; x++) {
    for (int y = 0; y < tiles[0].length; y++) {
      float screenXPos = x * tileSize + tileSize/2 + worldOffset;
      FTile tile = tiles[x][y];
      
      // tile is off screen left side
      if(screenXPos + tileSize/2 < 0) {
        if(tile != null) {
          world.removeBody(tile);
          tiles[x][y] = null;
        }
      }
      // tile is on screen
      if(screenXPos + tileSize/2 > 0  && screenXPos - tileSize/2 < width) {
        color c = mapImg.get(x, y);
        // if there should be a tile there but there isnt one
        if(tile == null && c != TRANSPARENT) {
          if(c == GROUND) {
            continue;
          }
          
          tile = new FTile(tileSize);
          tile.setFill(red(c), green(c), blue(c));
    
          tile.setPosition(x * tileSize + tileSize/2 + worldOffset, y * tileSize + tileSize/2);
          world.add(tile);
    
          tiles[x][y] = tile;
        }
      }
      
      if (tile != null) {
        tile.setPosition(x * tileSize + tileSize/2 + worldOffset, y * tileSize + tileSize/2);
      }
      
    }
  }
  
}
void updateGround() {
  for (int i = 0; i < groundTiles.size(); i++) {
    float xPos = (groundStartIdx + i) * groundTileSize + groundTileSize/2 + worldOffset;
    groundTiles.get(i).setPosition(xPos, groundY);
  }

  while (true) {
    float leftTileScreenX = (groundStartIdx) * groundTileSize + groundTileSize/2 + worldOffset;

    if (leftTileScreenX + groundTileSize/2 < 0) { 
      FTile t = groundTiles.remove(0);
      groundStartIdx++;

      int nextTileIdx = groundStartIdx + groundTiles.size(); // index for new right-most tile
      float newX = nextTileIdx*groundTileSize + groundTileSize/2 + worldOffset;

      t.setPosition(newX, groundY);  // move to end
      groundTiles.add(t);
    } else {
      break;
    }
  }
}


void updateObjects() {
  player.update();
}
void handleGravity() {
  world.setGravity(0, player.getVelocityY() > 0 ? fallingGravityStrength : normalGravityStrength);
}

void keyPressed() {
  if (key == ' ') spaceKeyDown = true;
}
void keyReleased() {
  if (key == ' ') spaceKeyDown = false;
}

PImage scaleImage(PImage src, int w, int h) {
  PImage out = createImage(w, h, ARGB);
  out.loadPixels();
  src.loadPixels();

  for (int y = 0; y < h; y++) {
    int sy = int(y * src.height / (float) h); 
    for (int x = 0; x < w; x++) {
      int sx = int(x * src.width / (float) w);
      out.pixels[y * w + x] = src.pixels[sy * src.width + sx];
    }
  }
  out.updatePixels();
  return out;
}
