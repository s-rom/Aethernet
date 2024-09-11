shader_type canvas_item;

uniform vec2 scroll_speed = vec2(1.0, 0.0);
uniform float time_scale = 1.0;
uniform float noise_scale = 5.0; // Escala del ruido de Perlin
uniform float threshold = 0.5; // Umbral para borrar las zonas
uniform float noise_speed = 1.0; // Velocidad del ruido de Perlin

// Función para generar ruido de Perlin
float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 ip = floor(p);
    vec2 u = fract(p);
    u = u*u*(3.0-2.0*u);

    float res = mix(
        mix(rand(ip), rand(ip + vec2(1.0, 0.0)), u.x),
        mix(rand(ip + vec2(0.0, 1.0)), rand(ip + vec2(1.0, 1.0)), u.x),
        u.y
    );

    return res*res;
}

void fragment() {
    // Calcular el desplazamiento en función del tiempo y la velocidad de desplazamiento
    vec2 scroll_offset = scroll_speed * TIME * time_scale;

    // Desplazar la coordenada de la textura y asegurarse de que se mantenga en el rango [0, 1]
    vec2 scrolled_uv = fract(UV + scroll_offset);

    // Generar el ruido de Perlin en las coordenadas UV con una componente temporal
    float perlin_noise = noise((UV * noise_scale) + vec2(TIME * noise_speed));

    // Aplicar la textura desplazada
    vec4 color = texture(TEXTURE, scrolled_uv);

    // Usar el ruido de Perlin para borrar zonas
    if (perlin_noise < threshold) {
        color.a = 0.0; // Hacer la zona transparente
    }

    COLOR = color;
}
