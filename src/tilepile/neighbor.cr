@[Flags]
enum Neighbor
  Up        = 0b00000001
  Down      = 0b00000010
  Left      = 0b00000100
  Right     = 0b00001000
  UpLeft    = 0b00010000
  UpRight   = 0b00100000
  DownLeft  = 0b01000000
  DownRight = 0b10000000
  Diagonals = UpLeft | UpRight | DownLeft | DownRight
  Adjacent  = Up | Down | Left | Right
end
