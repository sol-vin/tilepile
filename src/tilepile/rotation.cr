enum TilePile::Rotation
  None = 0
  CW1  = 1
  CW2  = 2
  CW3  = 3

  def rotate_cw : self
    v = self.value += 1
    v = None.value if v > CW3
    TilePile::Rotation.new(v)
  end

  def rotate_ccw : self
    v = self.value -= 1
    v = CW3.value if v < None
    TilePile::Rotation.new(v)
  end
end
