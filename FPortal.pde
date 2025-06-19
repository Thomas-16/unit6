class FPortal extends FCircle {
  private int mapX, mapY;
  
  public FPortal(int mapX, int mapY, float size, PImage image) {
    super(size);
    this.mapX = mapX;
    this.mapY = mapY;
    
    this.setPosition(mapX * tileSize + tileSize/2 + worldOffset, mapY * tileSize + tileSize/2);
    this.setSensor(true);
    this.setStatic(true); 
    this.setName("portal");
    this.attachImage(image);
  }
  
  public void update() {
    this.setPosition(mapX * tileSize + tileSize/2 + worldOffset, mapY * tileSize + tileSize/2);
  }
  
  public int getMapX() { return mapX; }
  public int getMapY() { return mapY; }
}
