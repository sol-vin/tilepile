class TilePile::Mouse
  CAMERA   = Raylib::MouseButton::Right
  INTERACT = Raylib::MouseButton::Left

  ZOOM_UNIT        =      0.1
  ZOOM_LIMIT_LOWER = 0.11_f32
  # Largest zoom possible
  ZOOM_LIMIT_UPPER = 12.0_f32

  ALL = [
    CAMERA,
    INTERACT,
    INFO,
  ]

  SCALE = 2.0

  getter position : Raylib::Vector2 = Raylib::Vector2.zero
  @previous_camera_mouse_drag_pos : Raylib::Vector2 = Raylib::Vector2.zero

  SMALL_CURSOR_ZOOM_LIMIT = 5.0

  def update
    @position.x = Raylib.get_mouse_x
    @position.y = Raylib.get_mouse_y
  end

  # Handles how the mouse moves the camera
  def handle_camera(camera : Raylib::Camera2D) : Raylib::Camera2D
    # Do the zoom stuff for MWheel
    mouse_wheel = Raylib.get_mouse_wheel_move * ZOOM_UNIT
    if !mouse_wheel.zero?
      camera.zoom = camera.zoom + mouse_wheel

      if camera.zoom < ZOOM_LIMIT_LOWER
        camera.zoom = ZOOM_LIMIT_LOWER
      elsif camera.zoom > ZOOM_LIMIT_UPPER
        camera.zoom = ZOOM_LIMIT_UPPER
      end
    end

    world_mouse = Raylib.get_screen_to_world_2d(@position, camera)

    # Handle panning
    if Raylib.mouse_button_pressed?(CAMERA)
      @previous_camera_mouse_drag_pos = @position
    elsif Raylib.mouse_button_down?(CAMERA)
      camera.target = camera.target - ((@position - @previous_camera_mouse_drag_pos) * 1/camera.zoom)

      @previous_camera_mouse_drag_pos = @position
    elsif Raylib.mouse_button_released?(CAMERA)
      @previous_camera_mouse_drag_pos.x = 0
      @previous_camera_mouse_drag_pos.y = 0
    end

    camera
  end
end
