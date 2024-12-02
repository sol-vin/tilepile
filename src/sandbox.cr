require "./tilepile"
include TilePile

automata(MyAutomata) do
  default_tile(index: 0, rotation: Rotation::None, bg: Color::BLACK, fg: Color::WHITE)
  
  rule do |x, y, data|
    if data.count_neighbors(x, y, 55) > 1
      data[x, y].with_index(400).with_fg(Color.new(128_u8, 128_u8, 128_u8))
    else
      data[x, y]
    end
  end
  
  on_click do |x, y, data, ctrl, alt, shift|
    if ctrl
      data[x, y].with_index(55)
    else
      data[x, y].with_index(102)
    end
  end
end

MyAutomata.run!(100, 100, "mrmo")
