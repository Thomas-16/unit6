class FPit extends FTile {
  
  public FPit(float width, float height, PImage[] images) {
    super(width, height);
    
    this.attachImage(images[(int)random(images.length)]);
    this.setName("pit");
  }
  
}
