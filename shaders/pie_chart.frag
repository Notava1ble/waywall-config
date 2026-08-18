precision highp float;

varying vec2 f_src_pos;

uniform sampler2D u_texture;

const float threshold = 0.01;

const vec3 entities = vec3(0.894, 0.275, 0.769);
const vec3 unspecified = vec3(0.275, 0.808, 0.400);
const vec3 destroy_progress = vec3(0.800, 0.424, 0.275);
const vec3 prepare = vec3(0.275, 0.298, 0.275);
const vec3 block_entities = vec3(0.925, 0.431, 0.306);

void main() {
    vec4 color = texture2D(u_texture, f_src_pos);

    bool is_entities = all(lessThan(abs(color.rgb - entities), vec3(threshold)));
    bool is_unspecified = all(lessThan(abs(color.rgb - unspecified), vec3(threshold)));
    bool is_destroy_progress = all(lessThan(abs(color.rgb - destroy_progress), vec3(threshold)));
    bool is_prepare = all(lessThan(abs(color.rgb - prepare), vec3(threshold)));
    bool is_block_entities = all(lessThan(abs(color.rgb - block_entities), vec3(threshold)));

    if (is_entities || is_unspecified || is_destroy_progress || is_prepare || is_block_entities) {
        gl_FragColor = color;
    } else {
        gl_FragColor = vec4(0.0);
    }
}
