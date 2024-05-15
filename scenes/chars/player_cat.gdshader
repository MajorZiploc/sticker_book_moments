shader_type canvas_item;

// Noise texture
uniform sampler2D noise_texture: repeat_enable, filter_nearest;
// Fog density
uniform float density: hint_range(0.0, 1.0) = 0.25;
// Fog speed
uniform vec2 speed = vec2(0.02, 0.01);
uniform vec4 fog_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);

void vertex() {
  // Called for every vertex the material is visible on.
}

void fragment() {
  // Called for every pixel the material is visible on.
  // reverse color values example
  // COLOR.rgb = COLOR.bgr;
  // float example
  float gray = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
  // gray scale
  COLOR = vec4(gray, gray, gray, COLOR.a);
  if (gray < 0.75) {
    // Make the fog slowly move
    vec2 uv = UV + speed * TIME;
    // Sample the noise texture
    float noise = texture(noise_texture, uv).r;
    // Convert the noise from the (0.0, 1.0) range to the (-1.0, 1.0) range
    // and clamp it between 0.0 and 1.0 again
    float fog = clamp(noise * 2.0 - 1.0, 0.0, 1.0);
    // Apply the fog effect
    COLOR.a *= fog * density;
    COLOR.rgb = fog_color.rgb;
  }
}

void light() {
  // Called for every pixel for every light affecting the CanvasItem.
}
