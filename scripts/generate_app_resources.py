import os
from PIL import Image, ImageDraw

def generate_resources():
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    source_logo_path = os.path.join(project_root, 'assets', 'ArtisanConnect Logo - 1.png')
    
    if not os.path.exists(source_logo_path):
        print(f"Source logo not found at {source_logo_path}")
        return

    img = Image.open(source_logo_path).convert('RGBA')
    bbox = img.getbbox()
    if not bbox:
        print("Empty image bounding box!")
        return

    # Crop out transparent padding from original high-res logo emblem
    cropped_logo = img.crop(bbox)

    canvas_size = 512
    # 300px circle fits 100% inside Android 66dp safe zone (out of 108dp total = 61.1%)
    circle_diameter = 300
    logo_target_size = 200

    # 1. Create transparent 512x512 foreground canvas
    foreground = Image.new('RGBA', (canvas_size, canvas_size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(foreground)

    # Draw warm white circle (#FFF6ED)
    circle_left = (canvas_size - circle_diameter) // 2
    circle_top = (canvas_size - circle_diameter) // 2
    circle_right = circle_left + circle_diameter
    circle_bottom = circle_top + circle_diameter

    draw.ellipse([circle_left, circle_top, circle_right, circle_bottom], fill=(255, 246, 237, 255))

    # Resize logo emblem to fit inside the warm white circle
    crop_w, crop_h = cropped_logo.size
    scale = logo_target_size / float(max(crop_w, crop_h))
    new_w, new_h = int(crop_w * scale), int(crop_h * scale)
    resized_logo = cropped_logo.resize((new_w, new_h), Image.Resampling.LANCZOS)

    # Paste logo emblem centered on warm white circle
    paste_x = (canvas_size - new_w) // 2
    paste_y = (canvas_size - new_h) // 2
    foreground.paste(resized_logo, (paste_x, paste_y), resized_logo)

    # Save to launcher_icon_foreground.png
    launcher_fg_path = os.path.join(project_root, 'assets', 'launcher_icon_foreground.png')
    foreground.save(launcher_fg_path, 'PNG')
    print(f"Successfully generated {launcher_fg_path} (size={foreground.size}, circle={circle_diameter}px, bbox={foreground.getbbox()})")

    # 2. Save launch_logo.png for native splash
    launch_logo_path = os.path.join(project_root, 'android', 'app', 'src', 'main', 'res', 'drawable', 'launch_logo.png')
    os.makedirs(os.path.dirname(launch_logo_path), exist_ok=True)
    foreground.save(launch_logo_path, 'PNG')
    print(f"Successfully generated {launch_logo_path}")

if __name__ == '__main__':
    generate_resources()
