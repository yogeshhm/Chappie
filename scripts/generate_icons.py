import math
import os
from PIL import Image, ImageDraw, ImageFilter

def create_cadence_icon(size=1024):
    # Canvas
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    
    # 1. Subtle drop shadow for the squircle
    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    s_draw = ImageDraw.Draw(shadow)
    margin = int(size * 0.06)
    corner_radius = int(size * 0.22)
    s_draw.rounded_rectangle(
        [margin, margin + int(size * 0.03), size - margin, size - margin + int(size * 0.03)],
        radius=corner_radius,
        fill=(0, 0, 0, 160)
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(int(size * 0.04)))
    img = Image.alpha_composite(img, shadow)

    # 2. Main rounded squircle background
    card = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    c_draw = ImageDraw.Draw(card)
    
    # Create smooth radial/linear gradient for background
    for y in range(margin, size - margin):
        t = (y - margin) / float(size - 2 * margin)
        # Gradient from #0F172A (slate 900) to #1E1B4B (indigo 950) to #0A0F1D
        r = int(12 * (1 - t) + 30 * t)
        g = int(20 * (1 - t) + 27 * t)
        b = int(38 * (1 - t) + 75 * t)
        c_draw.line([(margin, y), (size - margin, y)], fill=(r, g, b, 255))
        
    # Mask to rounded rectangle
    mask = Image.new("L", (size, size), 0)
    m_draw = ImageDraw.Draw(mask)
    m_draw.rounded_rectangle(
        [margin, margin, size - margin, size - margin],
        radius=corner_radius,
        fill=255
    )
    card.putalpha(mask)
    img = Image.alpha_composite(img, card)

    # 3. Ambient inner border / rim light
    rim = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    r_draw = ImageDraw.Draw(rim)
    r_draw.rounded_rectangle(
        [margin, margin, size - margin, size - margin],
        radius=corner_radius,
        outline=(255, 255, 255, 38),
        width=int(size * 0.007)
    )
    img = Image.alpha_composite(img, rim)

    # 4. Subtle background rhythm arcs / cadence concentric pulses
    cx, cy = size // 2, size // 2
    arc_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    a_draw = ImageDraw.Draw(arc_layer)
    for rad, alpha in [(size * 0.38, 14), (size * 0.44, 8)]:
        a_draw.arc(
            [cx - rad, cy - rad, cx + rad, cy + rad],
            start=40, end=320,
            fill=(56, 189, 248, alpha),
            width=int(size * 0.004)
        )
    img = Image.alpha_composite(img, arc_layer)

    # 5. Core Glyph: Modern Sculptural "C" + Soundwave Cadence Bars
    glyph_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    g_draw = ImageDraw.Draw(glyph_layer)

    # Outer Arc of C
    c_radius = int(size * 0.28)
    c_thickness = int(size * 0.088)
    bbox = [cx - c_radius, cy - c_radius, cx + c_radius, cy + c_radius]

    # Draw segmented gradient arc for the "C"
    # From angle 45 to 315 degrees
    num_steps = 180
    start_deg = 42
    end_deg = 318
    for i in range(num_steps):
        angle_deg = start_deg + (end_deg - start_deg) * (i / float(num_steps))
        next_deg = start_deg + (end_deg - start_deg) * ((i + 1) / float(num_steps))
        t = i / float(num_steps)
        # Gradient: Cyan (#06B6D4) -> Blue (#3B82F6) -> Violet/Indigo (#8B5CF6)
        if t < 0.5:
            st = t / 0.5
            r = int(6 * (1 - st) + 59 * st)
            g = int(182 * (1 - st) + 130 * st)
            b = int(212 * (1 - st) + 246 * st)
        else:
            st = (t - 0.5) / 0.5
            r = int(59 * (1 - st) + 139 * st)
            g = int(130 * (1 - st) + 92 * st)
            b = int(246 * (1 - st) + 246 * st)

        g_draw.arc(bbox, start=angle_deg, end=next_deg + 0.8, fill=(r, g, b, 255), width=c_thickness)

    # Rounded endcaps for the "C"
    rad1 = math.radians(start_deg)
    cap1_x = cx + c_radius * math.cos(rad1)
    cap1_y = cy + c_radius * math.sin(rad1)
    cap_r = c_thickness // 2
    g_draw.ellipse(
        [cap1_x - cap_r, cap1_y - cap_r, cap1_x + cap_r, cap1_y + cap_r],
        fill=(6, 182, 212, 255)
    )

    rad2 = math.radians(end_deg)
    cap2_x = cx + c_radius * math.cos(rad2)
    cap2_y = cy + c_radius * math.sin(rad2)
    g_draw.ellipse(
        [cap2_x - cap_r, cap2_y - cap_r, cap2_x + cap_r, cap2_y + cap_r],
        fill=(139, 92, 246, 255)
    )

    # 6. Inside Cadence Waveform / Rhythm Bars (representing outreach momentum)
    # 3 vertical pill bars inside the opening of the C
    bars = [
        (cx - int(size * 0.055), int(size * 0.075), (56, 189, 248)),   # Cyan short
        (cx + int(size * 0.025), int(size * 0.155), (99, 102, 241)),  # Indigo tall
        (cx + int(size * 0.105), int(size * 0.105), (139, 92, 246)),  # Violet medium
    ]
    bar_width = int(size * 0.038)
    bar_radius = bar_width // 2

    for bar_x, bar_h, col in bars:
        top_y = cy - bar_h // 2
        bottom_y = cy + bar_h // 2
        g_draw.rounded_rectangle(
            [bar_x - bar_radius, top_y, bar_x + bar_radius, bottom_y],
            radius=bar_radius,
            fill=(col[0], col[1], col[2], 255)
        )

    # 7. Add subtle glow from glyph
    glow = glyph_layer.filter(ImageFilter.GaussianBlur(int(size * 0.03)))
    # Blend glow with reduced opacity
    glow_data = glow.getdata()
    new_glow = []
    for item in glow_data:
        new_glow.append((item[0], item[1], item[2], int(item[3] * 0.45)))
    glow.putdata(new_glow)
    img = Image.alpha_composite(img, glow)
    img = Image.alpha_composite(img, glyph_layer)

    return img

def export_all():
    print("Generating Master 1024x1024 Cadence Icon...")
    master = create_cadence_icon(1024)
    os.makedirs("assets/branding", exist_ok=True)
    master.save("assets/branding/cadence_icon_master.png", "PNG")

    targets = {
        "android/app/src/main/res/mipmap-mdpi/ic_launcher.png": (48, 48),
        "android/app/src/main/res/mipmap-hdpi/ic_launcher.png": (72, 72),
        "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png": (96, 96),
        "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png": (144, 144),
        "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png": (192, 192),
        "web/favicon.png": (32, 32),
        "web/icons/Icon-192.png": (192, 192),
        "web/icons/Icon-512.png": (512, 512),
        "web/icons/Icon-maskable-192.png": (192, 192),
        "web/icons/Icon-maskable-512.png": (512, 512),
    }

    for path, (w, h) in targets.items():
        os.makedirs(os.path.dirname(path), exist_ok=True)
        resized = master.resize((w, h), Image.Resampling.LANCZOS)
        resized.save(path, "PNG")
        print(f"Generated: {path} ({w}x{h})")

if __name__ == "__main__":
    export_all()
