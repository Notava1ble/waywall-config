precision highp float;

varying vec2 f_src_pos;

uniform sampler2D u_texture;

const float threshold = 0.01;

const vec3 entities = vec3(0.882, 0.271, 0.761);
const vec3 block_entities = vec3(0.914, 0.427, 0.302);
const vec3 unspecified = vec3(0.271, 0.796, 0.396);

void main() {
    vec4 color = texture2D(u_texture, f_src_pos);

    bool is_entities = all(lessThan(abs(color.rgb - entities), vec3(threshold)));
    bool is_block_entities = all(lessThan(abs(color.rgb - block_entities), vec3(threshold)));
    bool is_unspecified = all(lessThan(abs(color.rgb - unspecified), vec3(threshold)));

    if (is_entities || is_block_entities || is_unspecified) {
        gl_FragColor = color;
    } else {
        gl_FragColor = vec4(0.0);
    }
}
