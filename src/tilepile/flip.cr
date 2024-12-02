@[Flags]
enum TilePile::Flip
  None = 0b00
  V    = 0b01
  H    = 0b10

  def flip_v : self
    self | V
  end

  def flip_h : self
    self | H
  end
end
