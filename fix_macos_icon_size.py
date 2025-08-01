#!/usr/bin/env python3
"""
Script para generar icono de macOS con fondo blanco más pequeño
para que el logo se vea más grande
"""

from PIL import Image, ImageDraw
import os

def create_smaller_background_icon(input_path, output_path, size=1024, corner_radius=180, bg_scale=0.80):
    """
    Crea un icono con fondo blanco más pequeño para que el logo se vea más grande
    
    Args:
        input_path: Ruta de la imagen original
        output_path: Ruta donde guardar el icono procesado
        size: Tamaño del icono (por defecto 1024x1024)
        corner_radius: Radio de las esquinas redondeadas
        bg_scale: Escala del fondo blanco (0.85 = 85% del tamaño total)
    """
    
    # Abrir la imagen original
    original = Image.open(input_path)
    
    # Convertir a RGBA si no lo está
    if original.mode != 'RGBA':
        original = original.convert('RGBA')
    
    # Crear imagen final transparente
    final_icon = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    
    # Calcular el tamaño del fondo blanco (más pequeño)
    bg_size = int(size * bg_scale)
    bg_offset = (size - bg_size) // 2
    
    # Crear fondo blanco más pequeño
    white_bg = Image.new('RGBA', (bg_size, bg_size), (255, 255, 255, 255))
    
    # Aplicar bordes redondeados al fondo blanco
    mask = Image.new('L', (bg_size, bg_size), 0)
    draw = ImageDraw.Draw(mask)
    # Ajustar el radio de esquina proporcionalmente
    adjusted_radius = int(bg_size * 0.22)
    draw.rounded_rectangle([0, 0, bg_size, bg_size], adjusted_radius, fill=255)
    white_bg.putalpha(mask)
    
    # Pegar el fondo blanco centrado en la imagen final
    final_icon.paste(white_bg, (bg_offset, bg_offset), white_bg)
    
    # Redimensionar el logo para que ocupe casi todo el fondo blanco
    logo_size = int(bg_size * 0.75)  # Logo ocupa 75% del fondo blanco
    original.thumbnail((logo_size, logo_size), Image.Resampling.LANCZOS)
    
    # Centrar el logo en toda la imagen (no solo en el fondo blanco)
    logo_x = (size - original.width) // 2
    logo_y = (size - original.height) // 2
    
    # Pegar el logo sobre el fondo blanco
    final_icon.paste(original, (logo_x, logo_y), original)
    
    # Guardar el resultado
    final_icon.save(output_path, 'PNG')
    print(f"✅ Icono de macOS generado con fondo blanco al {int(bg_scale*100)}%: {output_path}")

def main():
    # Rutas de archivos
    input_image = "images/QUIZ.png"
    output_image = "images/QUIZ_macos.png"
    
    # Verificar que existe la imagen original
    if not os.path.exists(input_image):
        print(f"❌ Error: No se encontró la imagen {input_image}")
        return

    # Crear el icono para macOS con fondo blanco 20% más pequeño
    create_smaller_background_icon(input_image, output_image, bg_scale=0.80)
    
    print("🎉 ¡Icono de macOS regenerado con fondo blanco más pequeño!")
    print(f"📁 Archivo actualizado: {output_image}")
    print("💡 El logo ahora se verá más grande porque el fondo blanco es más pequeño")

if __name__ == "__main__":
    main()