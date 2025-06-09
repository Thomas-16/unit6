class FPlayer extends FBox {
  private final int jumpStrength = 1150;
  private int xPos;
  
  public FPlayer(int x, int y, float w, float h, PImage playerImg) {
    super(w, h);
    this.xPos = x;
    
    this.setPosition(x, y);
    this.attachImage(playerImg);
    this.setName("player");
  }
  
  public void update() {
    handlePlayerMovement();
  }
  
  private void handlePlayerMovement() {
    this.setPosition(xPos, this.getY());
    if(spaceKeyDown && isGrounded()) {
      jump();
    }
  }
  
  public void jump() {
    this.setVelocity(0, -jumpStrength);
    this.setAngularVelocity(PI);
  }
  
  public boolean isGrounded() {
    return this.getContacts().size() != 0;
  }
}
