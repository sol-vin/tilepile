require "yaml"

module TilePile
  macro automata(name = TilePile::Automata, &block)
    module {{name}}
      include TilePile

      alias GenProc = Proc(Int32, Int32, Data, Tile)

      alias R = Raylib

      {{block.body}}

      macro finished

        private def self._run_procs(x, y, procs, internal_data : InternalData)
          procs.each do |proc|
            internal_data[x, y] = proc.call(x, y, internal_data.to_data)
          end

          internal_data.copy
        end

        private def self._recalculate_camera(camera : R::Camera2D) : R::Camera2D
          camera.offset = R::Vector2.new(x: R.get_screen_width/2.0_f32, y: R.get_screen_height/2.0_f32)
          camera
        end

        def self.run!(width, height, tileset_name)
          R.init_window(480*2, 320*2, "#{{{name}}}")
          R.set_target_fps(60)
          
          procs = [\{{@type.constants.select {|c| c =~ /^PROC__\d+$/ }.map(&.id).join(",").id}}] of GenProc
          
          data = InternalData.new(width.to_u32, height.to_u32, DEFAULT_TILE)
          
          total_time = Time::Span.new(nanoseconds: 0)
          elapsed_time = Time::Span.new(nanoseconds: 0)
          
          frame_timer = Timer.new(0.25.seconds)
          frame_timer.loop = true
          frame_timer.start
          
          frame_timer.on_triggered do |total_time, elapsed_time|
            time = Time.measure do
              width.times do |x|
                height.times do |y|
                  _run_procs(x, y, procs, data)
                end
              end
            end

            puts "Frame time: #{time}"
          end

          camera = _recalculate_camera(R::Camera2D.new(zoom: 1.0_f32))
          mouse = TilePile::Mouse.new

          tileset = Tileset.new(tileset_name)
          
          until R.close_window?
            frame_timer.tick(total_time, elapsed_time)

            \{% if @type.has_constant?("ON_CLICK_PROC")%}
            if Raylib.mouse_button_down?(Raylib::MouseButton::Left)

              mouse_xy = Raylib.get_screen_to_world_2d(mouse.position, camera) / Raylib::Vector2.new(x: tileset.tile_width, y: tileset.tile_height)

              unless mouse_xy.x.to_i >= width || mouse_xy.y.to_i >= height || mouse_xy.x.to_i < 0 || mouse_xy.y.to_i < 0
                data[mouse_xy.x.to_i, mouse_xy.y.to_i] = ON_CLICK_PROC.call(
                  mouse_xy.x.to_i, mouse_xy.y.to_i,
                  data.to_data,
                  R.key_down?(Raylib::KeyboardKey::LeftControl) || R.key_down?(Raylib::KeyboardKey::RightControl),
                  R.key_down?(Raylib::KeyboardKey::LeftAlt) || R.key_down?(Raylib::KeyboardKey::RightAlt),
                  R.key_down?(Raylib::KeyboardKey::LeftShift) || R.key_down?(Raylib::KeyboardKey::RightShift)
                )

                data.copy
              end
            end
            \{% end %}

            elapsed_time = Time.measure do
              mouse.update

              camera = _recalculate_camera(camera)
              camera = mouse.handle_camera(camera)
              
              # Draw Logic
              R.begin_drawing
              R.clear_background(R::BLACK)
              
              R.begin_mode_2d(camera)
              
              real_tile_size = R.get_world_to_screen_2d(R::Vector2.new(x: tileset.tile_width, y: tileset.tile_height), R::Camera2D.new(zoom: camera.zoom))
              if real_tile_size.x.abs < tileset.tile_width*0.75 || real_tile_size.y.abs < tileset.tile_height*0.75
                width.times do |x|
                  height.times do |y|
                    if data[x, y].index == 0
                      R.draw_rectangle(x * tileset.tile_width, y * tileset.tile_height, tileset.tile_width, tileset.tile_height, data[x, y].bg.to_raylib)
                    else
                      R.draw_rectangle(x * tileset.tile_width, y * tileset.tile_height, tileset.tile_width, tileset.tile_height, data[x, y].fg.to_raylib)
                    end
                  end
                end
              else
                width.times do |x|
                  height.times do |y|
                    tileset.draw_tile(data[x, y], x * tileset.tile_width, y * tileset.tile_height)
                  end
                end
              end

              R.end_mode_2d
              R.end_drawing
            end

            total_time += elapsed_time
          end

          tileset.unload

          R.close_window
        end
      end
    end
  end

  macro rule(&block)
    {% raise "Wrong number of arguments in generate block. You must include an x, y, and data, argument" if block.args.size != 3 %}
    {%
      i = 0
      stack = [nil]
      stack.each do |_| # (While)
        stack << nil    # (Seed the next loop)
        if @type.has_constant?("PROC__#{i}")
          i += 1
        else
          stack.clear # (Break)
        end
      end
    %}
    
    PROC__{{i}} = GenProc.new do |{{block.args[0]}}, {{block.args[1]}}, {{block.args[2]}}| 
      {{block.body}}
    end
  end

  macro default_tile(index = 0_u32, rotation = Rotation::None, bg = Color::BLACK, fg = Color::WHITE, flip = Flip::None)
    DEFAULT_TILE = Tile.new(index: {{index}}, rotation: {{rotation}}, bg: {{bg}}, fg: {{fg}}, flip: {{flip}})
  end

  macro on_click(&block)
    {% raise "Wrong argument count! was #{block.args.size} and 3-6 required for block." unless block.args.size >= 3 && block.args.size <= 6 %}

    ON_CLICK_PROC = ->({{block.args[0]}} : Int32, {{block.args[1]}} : Int32, {{block.args[2]}} : TilePile::Data, {{block.args[3] ? block.args[3] : "_".id}} : Bool, {{block.args[4] ? block.args[4] : "_".id}} : Bool, {{block.args[5] ? block.args[5] : "_".id}} : Bool) do
      {{block.body}}
    end
  end
end
