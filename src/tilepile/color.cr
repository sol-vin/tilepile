struct TilePile::Color
  WHITE = self.new(0xFF_u8, 0xFF_u8, 0xFF_u8)
  BLACK = self.new(0x00_u8, 0x00_u8, 0x00_u8)

  RED   = self.new(0xFF_u8, 0x00_u8, 0x00_u8)
  GREEN = self.new(0x00_u8, 0xFF_u8, 0x00_u8)
  BLUE  = self.new(0x00_u8, 0x00_u8, 0xFF_u8)

  property r : UInt8 = 0_u8
  property g : UInt8 = 0_u8
  property b : UInt8 = 0_u8

  def initialize(@r, @g, @b)
  end

  def to_raylib
    Raylib::Color.new(r: r, g: g, b: b, a: 255_u8)
  end
end
