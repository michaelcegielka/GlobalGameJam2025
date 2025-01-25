shader_type spatial;

uniform sampler2D dirt_texture;
uniform sampler2D mask_texture;

void fragment() {
    vec4 dirt_color = texture(dirt_texture, UV);
    float mask_value = texture(mask_texture, UV).r;

   ALBEDO = dirt_color.rgb * mask_value;
    ALPHA = mask_value;
}