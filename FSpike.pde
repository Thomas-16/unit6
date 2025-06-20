class FSpike extends FTile {
  
  public FSpike(float width, float height, PImage image, boolean isFlipped) {
    super(width, height);
    
    this.attachImage(isFlipped ? flipImage(image) : image);
    this.setName("spike");
  }
  
}
