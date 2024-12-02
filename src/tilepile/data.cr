class TilePile::InternalData
  @current = Slice(Tile).new(1) { Tile.new }
  @last = Slice(Tile).new(1) { Tile.new }

  getter width : UInt32
  getter height : UInt32

  def initialize(@width : UInt32, @height : UInt32, default_tile = Tile.new)
    @current = Slice(Tile).new((@width * @height).to_i32, default_tile)
    @last = Slice(Tile).new((@width * @height).to_i32, default_tile)
  end

  def copy
    @current.copy_to(@last)
  end

  def [](x, y)
    @last[y * width + x]
  end

  def []?(x, y)
    return nil if x < 0 || y < 0 || x >= width || y >= height
    @last[y * width + x]
  end

  def []=(x, y, tile : Tile)
    @current[y * width + x] = tile
  end

  def current
    # Must be read-only! Do not pass non-readonly Slices!
    Slice(Tile).new(@current.to_unsafe, @width * @height, read_only: true)
  end

  def last
    # Must be read-only! Do not pass non-readonly Slices!
    Slice(Tile).new(@last.to_unsafe, @width * @height, read_only: true)
  end

  def to_data
    TilePile::Data.new(width, height, self.last)
  end
end

class TilePile::Data
  @last = Slice(Tile).new(1) { Tile.new }

  getter width : UInt32
  getter height : UInt32

  def initialize(@width : UInt32, @height : UInt32, @last : Slice(Tile))
  end

  def [](x, y)
    @last[y * width + x]
  end

  def []?(x, y)
    return nil if x < 0 || y < 0 || x >= width || y >= height
    @last[y * width + x]
  end

  def count_neighbors(x, y, neighborhood : Neighbor = Neighbor::All) : UInt8
    n = 0_u8
    if neighborhood.up?
      n += 1 if (t = self[x, y - 1]?) && t.index != 0
    end

    if neighborhood.down?
      n += 1 if (t = self[x, y + 1]?) && t.index != 0
    end

    if neighborhood.left?
      n += 1 if (t = self[x - 1, y]?) && t.index != 0
    end

    if neighborhood.right?
      n += 1 if (t = self[x + 1, y]?) && t.index != 0
    end

    if neighborhood.up_left?
      n += 1 if (t = self[x - 1, y - 1]?) && t.index != 0
    end

    if neighborhood.down_left?
      n += 1 if (t = self[x - 1, y + 1]?) && t.index != 0
    end

    if neighborhood.up_right?
      n += 1 if (t = self[x + 1, y - 1]?) && t.index != 0
    end

    if neighborhood.down_right?
      n += 1 if (t = self[x + 1, y + 1]?) && t.index != 0
    end

    n
  end

  def count_neighbors(x, y, type, neighborhood : Neighbor = Neighbor::All) : UInt8
    n = 0_u8
    if neighborhood.up?
      n += 1 if (t = self[x, y - 1]?) && t.index == type
    end

    if neighborhood.down?
      n += 1 if (t = self[x, y + 1]?) && t.index == type
    end

    if neighborhood.left?
      n += 1 if (t = self[x - 1, y]?) && t.index == type
    end

    if neighborhood.right?
      n += 1 if (t = self[x + 1, y]?) && t.index == type
    end

    if neighborhood.up_left?
      n += 1 if (t = self[x - 1, y - 1]?) && t.index == type
    end

    if neighborhood.down_left?
      n += 1 if (t = self[x - 1, y + 1]?) && t.index == type
    end

    if neighborhood.up_right?
      n += 1 if (t = self[x + 1, y - 1]?) && t.index == type
    end

    if neighborhood.down_right?
      n += 1 if (t = self[x + 1, y + 1]?) && t.index == type
    end

    n
  end

  def last
    # Must be read-only! Do not pass non-readonly Slices!
    Slice(Tile).new(@last.to_unsafe, @width * @height, read_only: true)
  end
end
