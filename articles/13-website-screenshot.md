# Mindory Website Screenshot Production Guide

High-quality screenshots are essential for showcasing the Mindory app on the official website. They convey the product's key features, user experience, and premium feel. This guide summarizes the **design principles, workflow, and tools** used to produce professional screenshots for the Mindory website.

---

## Design Philosophy

- **Highlight core features**: Book list on Home, AI chat on Reading page, contextual highlights.  
- **Premium visual feel**: Clean, elegant, with sufficient whitespace to emphasize content.  
- **Static consistency**: Avoid dynamic content or animations to ensure reproducibility.  
- **Retina-ready output**: High resolution ensures sharpness on all screens.  
- **Content restraint**: Less content creates more focus. The screenshot should guide attention, not overwhelm it.

---

## Screenshot Principles

1. **Limit visible content**
   - Display **no more than 3 books** on the Home screen.
   - Three items are visually balanced and avoid crowding.
   - Extra items reduce clarity and weaken the premium feel.

2. **Use proper aspect ratios**
   - Recommended product image ratios: **16:9** or **16:10**.
   - Avoid square (1:1) screenshots for website banners.
   - Wider ratios feel more cinematic and professional, especially in hero sections.

3. **Static example data**
   - Fix 3 books on Home.
   - Fixed AI chat and highlighted quotes.
   - Disable loading animations.

4. **Consistent visual style**
   - Rounded corners and soft shadows on cards.
   - Subtle background gradients or blur.
   - Uniform fonts, clear headings and subheadings.

5. **Dialog background handling**
   - Default dialog overlays often use dark gray/black backdrops.
   - These overlays can negatively affect the official website’s clean visual style.
   - When capturing screenshots, temporarily weaken or soften the dark overlay via code (e.g., reduce opacity or adjust backdrop blur).
   - Ensure the modal remains readable while preserving brand aesthetics.

6. **High-resolution output**
   - Hero / Banner recommended size: 1440×900 (1x), Retina 2x: 2880×1800.

7. **Remove distractions**
   - Hide macOS menu bar and Dock.
   - Remove window decorations (title bar, borders).

---

## Screenshot Workflow

### Step 1: Prepare Tauri App Window

- Enable **Showcase Mode** in development to stabilize displayed data.  
- Tauri window configuration (`tauri.conf.json`):

```json
"windows": [
  {
    "width": 1440,
    "height": 900,
    "resizable": false,
    "fullscreen": false,
    "decorations": false
  }
]
````

* Close all animations and dynamic loading.
* Ensure dialog overlays are visually optimized before capture.

---

### Step 2: Capture Screenshot

**Tool**: **Shottr** (free) or **CleanShot X** (premium)

* Capture the **App window only**, not the full screen, to avoid menu bar or Dock.
* Save as **PNG**, original resolution (e.g., 2972×1892, RGB).
* Verify no unintended transparency or dark overlay artifacts are present.

---

## Recommended Tools

| Category   | Tool        | Purpose                                       |
| ---------- | ----------- | --------------------------------------------- |
| Screenshot | Shottr      | Free, window capture                          |
| Screenshot | CleanShot X | Premium, hides menu bar & Dock, Retina export |

---

## Summary

By combining:

* Tauri Showcase mode
* High-resolution screenshots
* Controlled content density (3 books only)
* Proper aspect ratios (16:9 or 16:10)
* Optimized dialog overlay styling

we can produce a set of clean, high-end, and consistent screenshots for the Mindory website.

These images are ready for:

* Hero section
* Feature demonstration
* Marketing assets

This workflow ensures reproducibility, Retina sharpness, visual clarity, and a polished brand presentation.