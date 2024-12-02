class TilePile::Tileset
  property width : Int32
  property height : Int32
  property tile_width : Int32
  property tile_height : Int32
  property texture : Raylib::Texture2D

  def initialize(name : String)
    @texture = Raylib.load_texture("./rsrc/#{name}.png")

    tile_yaml_raw = ""

    File.open("./rsrc/#{name}.yaml") do |file|
      tile_yaml_raw = file.gets_to_end
    end

    raise "Cannot load tile size" if tile_yaml_raw.empty?

    tile_yaml = YAML.parse(tile_yaml_raw)

    @tile_width = tile_yaml["width"].as_i
    @tile_height = tile_yaml["height"].as_i

    @width = (texture.width / tile_width).to_i
    @height = (texture.height / tile_width).to_i
  end

  def total_tiles
    width * height
  end

  def draw_tile(tile : Tile, x, y)
    if tile.index == 0
      Raylib.draw_rectangle(x - tile_width/2, y - tile_height/2, tile_width, tile_height, tile.bg.to_raylib)
    elsif tile.index == 1
      Raylib.draw_rectangle(x - tile_width/2, y - tile_height/2, tile_width, tile_height, tile.fg.to_raylib)
    else
      Raylib.draw_rectangle(x - tile_width/2, y - tile_height/2, tile_width, tile_height, tile.bg.to_raylib)
      ti = tile.index - 2
      tx = (ti % width) * tile_width
      ty = (ti / width).to_i * tile_height
      rotation = 0.0
      rotation = 90.0 if tile.rotation.cw1?
      rotation = 180.0 if tile.rotation.cw2?
      rotation = 270.0 if tile.rotation.cw3?

      Raylib.draw_texture_pro(
        @texture,
        Raylib::Rectangle.new(x: tx, y: ty, width: tile_width, height: tile_height),
        Raylib::Rectangle.new(x: x, y: y, width: tile_width, height: tile_height),
        Raylib::Vector2.new(x: tile_width/2, y: tile_height/2),
        rotation,
        tile.fg.to_raylib
      )
    end
  end

  def unload
    Raylib.unload_texture(@texture)
  end
end
