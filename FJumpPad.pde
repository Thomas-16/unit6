class FJumpPad extends FCircle {
  private int mapX;
  private int mapY;
  private final int offset = 43;
  
  public FJumpPad(int mapX, int mapY, int size, PImage image) {
    super(size);
    this.mapX = mapX;
    this.mapY = mapY;
    
    this.setPosition(mapX * tileSize + tileSize/2 + worldOffset, mapY * tileSize + tileSize/2 + offset);
    this.setStatic(true); 
    this.setSensor(true);
    this.attachImage(image);
    this.setName("jumppad");
  }
  
  public void update() {
    this.setPosition(mapX * tileSize + tileSize/2 + worldOffset, mapY * tileSize + tileSize/2 + offset);
  }
  
  public int getMapX() { return mapX; }
  public int getMapY() { return mapY; }
  
}
