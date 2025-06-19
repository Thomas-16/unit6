import fisica.*;

// TODOS:
// 

// colors
color TRANSPARENT = color(0,0,0,0);
color GROUND = #2f3699;
color SPIKE = #ed1c24;
color REGBLOCK1 = #00f094;
color REGBLOCK1FLIPPED = #00e0f0;
color BLOCK8 = #7dbf7a;
color PIT = #ff7e00;
color PORTAL = #d400ff;

PImage mapImg;
PImage playerImg;
PImage backgroundImg;
PImage groundTileImg;
PImage spikeImg;
PImage portalImg;

PImage regBlock1Img;
PImage regBlock1FlippedImg;
PImage block1Img;
PImage block2Img;
PImage block3Img;
PImage block5Img;
PImage block7Img;
PImage block8Img;
PImage[] pitImgs;

FPlayer player;
FWorld world;
FTile[][] tiles;
ArrayList<FTile> groundTiles;
ArrayList<FPortal> portals;

final float groundY = 900;
int groundStartIdx;      
int groundVisibleCount;

float bgOffset;
final float bgScrollSpeed = 1.6;

int normalGravityStrength = 3700;
int fallingGravityStrength = 5900;
int worldMovingSpeed = 8;

float worldOffset;
boolean isGravityFlipped;
int lastPortalFlipTime;

// input
boolean spaceKeyDown;

final int tileSize = 60;
final int groundTileSize = tileSize*4;

void setup() {
  size(1800, 1000, P2D);
  frameRate(60);
  Fisica.init(this);
  
  mapImg = loadImage("map.png");
  playerImg = scaleImage(loadImage("player.png"), tileSize, tileSize);
  backgroundImg = scaleImage(loadImage("background.png"), width, height);
  groundTileImg = scaleImage(loadImage("groundTile.png"), groundTileSize, groundTileSize);
  spikeImg = scaleImage(loadImage("RegularSpike01.png"), tileSize, tileSize);
  regBlock1Img = scaleImage(loadImage("RegularBlock01.png"), tileSize, tileSize);
  regBlock1FlippedImg = flipImage(regBlock1Img);
  block1Img = scaleImage(loadImage("GridBlock01.png"), tileSize, tileSize);
  block2Img = scaleImage(loadImage("GridBlock02.png"), tileSize, tileSize);
  block3Img = scaleImage(loadImage("GridBlock03.png"), tileSize, tileSize);
  block5Img = scaleImage(loadImage("GridBlock05.png"), tileSize, tileSize);
  block7Img = scaleImage(loadImage("GridBlock07.png"), tileSize, tileSize);
  block8Img = scaleImage(loadImage("GridBlock08.png"), tileSize, tileSize);
  pitImgs = new PImage[] { 
    scaleImage(loadImage("ThornPit01.png"), tileSize, tileSize), 
    scaleImage(loadImage("ThornPit02.png"), tileSize, tileSize), 
    scaleImage(loadImage("ThornPit03.png"), tileSize, tileSize)
  };
  portalImg = scaleImage(loadImage("CubePortal.png"), int(186 * 0.75), int(339 * 0.75));
  
  setupScene();
}
void setupScene() {
  world = new FWorld();
  world.setGravity(0, normalGravityStrength);
  world.setGrabbable(false);
  world.setEdges();
  
  tiles = new FTile[mapImg.width][mapImg.height];
  groundTiles = new ArrayList<FTile>();
  groundStartIdx = 0;
  groundVisibleCount = ceil(width / (float)groundTileSize) + 1;
  
  bgOffset = 0;
  worldOffset = 0;
  isGravityFlipped = false;
  lastPortalFlipTime = 0;

  for (int i = 0; i < groundVisibleCount; i++) {
    FTile g = new FTile(groundTileSize, groundTileSize);
    g.attachImage(groundTileImg);
    g.setPosition(i*groundTileSize + groundTileSize/2, groundY);
    world.add(g);
    groundTiles.add(g);
  }
  
  portals = new ArrayList<FPortal>();
  
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
  
  worldOffset -= worldMovingSpeed;
  updateTiles();
  updateGroundTiles();
  
  updateObjects();
  handlePlayerCollisions();
  
  world.step();
  world.draw();
  //world.drawDebug();
  //world.drawDebugData();
  //popMatrix();
}

void handlePlayerCollisions() {
  ArrayList<FContact> contacts = player.getContacts();
  for (FContact c : contacts) {
    if (c.contains("spike") || c.contains("pit")) {
      playerDies();
      return;
    }
    if(c.contains("portal")) {
      return;
    }

    // normal vector of collision
    float ny = c.getNormalY();
    if (c.getBody2() == player) ny = -ny;
    
    if ((!isGravityFlipped && ny < -0.5) || (isGravityFlipped && ny > 0.5)) {
      playerDies();
      return;
    }
  }
}


void updateTiles() {
  for (int x = 0; x < tiles.length; x++) {
    maploop:
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
          // handled seperately
          if(c == GROUND) {
            continue;
          }
          if(c == SPIKE) {
            tile = new FSpike(tileSize * 0.7, tileSize/3, spikeImg);
          } else if(c == PIT) {
            tile = new FPit(tileSize, tileSize/3, pitImgs);
          } else if(c == PORTAL) {
            for(FPortal portal : portals) {
              // if a portal already exists there
              if(portal.getMapX() == x && portal.getMapY() == y) {
                continue maploop;
              }
            }
            
            FPortal portal = new FPortal(x, y, 186 * 0.75, portalImg);
            portals.add(portal);
            world.add(portal);
            continue;
          } else if(c == REGBLOCK1) {
            tile = new FTile(tileSize, tileSize);
            tile.attachImage(regBlock1Img);
          } else if(c == REGBLOCK1FLIPPED) {
            tile = new FTile(tileSize, tileSize);
            tile.attachImage(regBlock1FlippedImg);
          } else if(c == BLOCK8) {
            tile = new FTile(tileSize, tileSize);
            tile.attachImage(block8Img);
          }
          else {
            println("invalid tile colour");
            continue;
          }
          
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
void updateGroundTiles() {
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

void contactStarted(FContact c) {
  if (c.contains("portal", "player")) {
    if (millis() - lastPortalFlipTime >= 2000) {
      isGravityFlipped  = !isGravityFlipped;
      lastPortalFlipTime = millis();
    }
  }
}


void updateObjects() {
  player.update();
  
  for(FPortal portal : portals) {
    portal.update();
  }
  ArrayList<Integer> portalsToRemove = new ArrayList<Integer>();
  for(int i = 0; i < portals.size(); i++) {
    if(portals.get(i).getX() < -100) {
      portalsToRemove.add(i);
    }
  }
  for(int i = 0; i < portalsToRemove.size(); i++) {
    FPortal portalToRemove = portals.get(portalsToRemove.get(i) - i);
    world.removeBody(portalToRemove);
    portals.remove(portalToRemove);
  }
}
void handleGravity() {
  int targetGravity;
  if((player.getVelocityY() > 0 && !isGravityFlipped) || (player.getVelocityY() < 0 && isGravityFlipped)) {
    targetGravity = fallingGravityStrength;
  } else {
    targetGravity = normalGravityStrength;
  }
  if(isGravityFlipped) {
    targetGravity *= -1;
  }
  
  world.setGravity(0, targetGravity);
}

void playerDies() {
  setupScene();
}

void keyPressed() {
  if (key == ' ') spaceKeyDown = true;
  if (key == 'g') isGravityFlipped = !isGravityFlipped;
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
PImage flipImage(PImage src) {
  PImage dst = createImage(src.width, src.height, ARGB);
  src.loadPixels();
  dst.loadPixels();

  int w = src.width;
  int h = src.height;

  for (int y = 0; y < h; y++) {
    int srcRow = y * w;  
    int dstRow = (h - 1 - y) * w; 

    for (int x = 0; x < w; x++) {
      dst.pixels[dstRow + x] = src.pixels[srcRow + x];
    }
  }
  dst.updatePixels();
  return dst;
}
