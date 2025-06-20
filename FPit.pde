class FPit extends FTile {
  
  public FPit(float width, float height, PImage[] images, boolean isFlipped) {
    super(width, height);
    
    this.attachImage(isFlipped ? flipImage(images[(int)random(images.length)]) : images[(int)random(images.length)]);
    this.setName("pit");
  }
  
}
