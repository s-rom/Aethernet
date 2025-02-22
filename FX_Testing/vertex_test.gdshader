// Shader de deformación por ondas en Godot 4 para un Sprite2D (corrige bandas negras)
shader_type canvas_item;

// Variables uniformes para controlar la onda
uniform float amplitude : hint_range(0.0, 10.0) = 5.0; // Altura de la onda
uniform float frequency : hint_range(0.0, 10.0) = 3.0; // Frecuencia de la onda
uniform float speed : hint_range(0.0, 5.0) = 1.0; // Velocidad de la onda

void fragment() {
    // Calculamos el desplazamiento senoidal basado en la coordenada UV y el tiempo
    float wave = sin(UV.x * frequency + TIME * speed) * amplitude / 100.0;

    // Desplazamos la coordenada UV en Y asegurando que no salga del rango válido
    vec2 distorted_uv = UV;
    distorted_uv.y = clamp(UV.y + wave, 0.0, 1.0);

    // Aplicamos la textura con la UV modificada
    COLOR = texture(TEXTURE, distorted_uv);
}