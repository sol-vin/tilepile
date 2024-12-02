struct TilePile::Tile
  property index : UInt32 = 0_u32
  property bg : Color = Color::BLACK
  property fg : Color = Color::WHITE
  property rotation : Rotation = Rotation::None
  property flip : Flip = Flip::None

  def initialize(@index : UInt32 = 0_u32, @fg : Color = Color::WHITE, @bg : Color = Color::WHITE, @rotation : Rotation = Rotation::None, @flip : Flip = Flip::None)
  end

  def with_index(i : UInt32)
    @index = i
    self
  end

  def with_bg(color : Color)
    @bg = color
    self
  end

  def with_fg(color : Color)
    @fg = color
    self
  end

  def with_rotation(rotation : Rotation)
    @rotation = rotation
    self
  end

  def with_flip(flip : Flip)
    @flip = flip
    self
  end
end
