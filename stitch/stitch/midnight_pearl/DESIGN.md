# Design System Document: The Ethereal Estate Framework

## 1. Overview & Creative North Star: "The Celestial Curator"

The design system is built upon the "Celestial Curator" North Star. Unlike standard real estate platforms that rely on rigid grids and heavy borders, this system treats the interface as a digital gallery. It balances the weight of professional "Dark Graphite" with the airy, weightless quality of "Pearl" glass.

To break the "template" look, the system leverages intentional asymmetry—shifting property details off-center to create an editorial feel—and high-contrast typography scales. We move away from the "app" feel and toward a luxury magazine experience where elements breathe, overlap, and react to light.

## 2. Colors & Surface Architecture

The palette is anchored by the tension between the depth of the night sky and the luminescence of a pearl.

### The Palette
*   **Primary (#767777):** Used for high-authority actions and text. A deep, dark graphite tone.
*   **Secondary (#777777):** Our "Soft Graphite" interactive pulse. Used for focus states, active filters, and accents.
*   **Surface Hierarchy:**
    *   `surface-container-lowest`: #FFFFFF (Used for pure white highlights).
    *   `surface-container-low`: #F3F4F5 (The base for subtle nesting).
    *   `surface-container-highest`: #E1E3E4 (The "deepest" frosted layer).

### The "No-Line" Rule
Traditional 1px solid borders are strictly prohibited for sectioning. Structural boundaries must be defined through:
1.  **Tonal Transitions:** A `surface-container-low` card resting on the mesh gradient background.
2.  **Backdrop Blurs:** Using the 20px blur to naturally distort the background, creating a perceived edge without a physical line.

### Glass & Gradient Rule
All primary containers must utilize Glassmorphism.
*   **Formula:** `surface-container-lowest` at 15% opacity + 20px Backdrop Blur.
*   **Signature Textures:** For Hero CTAs, use a subtle linear gradient transitioning from `primary` (#767777) to `primary-container` (#8A8B8B) to add a sense of "ink-like" depth.

## 3. Typography: The Editorial Voice

We utilize a dual-font approach (Manrope/Inter) to simulate high-end print media.

*   **Display & Headlines (Manrope):** These are our "Art Pieces." Large scales (`display-lg` at 3.5rem) should be used with tight letter spacing (-0.02em) to feel authoritative and modern.
*   **Titles & Body (Inter/SF Pro):** Designed for maximum legibility. `body-lg` (1rem) provides the clarity needed for technical property details.
*   **Visual Hierarchy:** Titles should always be at least 2 steps larger than body text to ensure a clear "editorial" entry point for the eye.

## 4. Elevation & Depth: Tonal Layering

We reject the traditional drop shadow in favor of "Ambient Luminosity."

*   **The Layering Principle:** Depth is achieved by stacking. A "Pearl" glass card (`surface-container-lowest` at 15%) should be placed over the mesh gradient. If an inner element (like a "Book Viewing" button) needs prominence, it uses the `primary` dark graphite color to visually "sink" into the glass or "pop" through contrast.
*   **Ambient Shadows:** For floating elements (Modals/Sheets), use a shadow with a 40px blur at 6% opacity, tinted with the `surface-tint` (#767777) rather than black.
*   **The Squircle Standard:** To maintain the Apple HIG "Premium" feel, use a 32pt Squircle (Continuous Curve) for all main containers (`xl` roundedness). This creates a softer, more organic silhouette than standard radii.
*   **The "Ghost Border" Fallback:** If a container requires definition against a light background, use a 1px border of `outline-variant` at 20% opacity. Never use 100% opaque lines.

## 5. Components

### Buttons
*   **Primary:** `primary` (#767777) background, `on-primary` (#FFFFFF) text. 16pt `md` roundedness. High-gloss finish.
*   **Secondary:** Glass-morphic (15% white, 20px blur) with a `secondary` (#777777) text label.
*   **Interaction:** On press, the button should scale to 97% and increase backdrop blur density.

### Cards & Property Lists
*   **The Rule of Space:** Forbid the use of divider lines between list items. Separate properties using the Spacing Scale (compact spacing is used for a refined feel, aligning with the "editorial" tone) or by alternating the `surface-container` tiers.
*   **Image Handling:** Property images should use a 24pt Squircle radius to nest perfectly within the 32pt main glass container.

### Input Fields
*   **Styling:** Minimalist. No bottom line. Use a `surface-container-low` background with a soft `label-sm` floating above the input.
*   **Focus State:** The "Ghost Border" becomes 100% `secondary` dark graphite.

### Signature Component: The "Lustre" Property Card
A large-format card featuring a full-bleed property image. Data overlays are rendered in a "Dark Graphite" glass strip at the bottom (15% dark graphite opacity, 30px blur) to ensure the white "Pearl" text remains legible against varied photography.

## 6. Do's and Don'ts

### Do
*   **DO** use whitespace as a structural element. If an interface feels "busy," increase the gap between glass cards rather than adding a border.
*   **DO** allow the multi-colored mesh gradient to peek through containers. This creates "visual soul."
*   **DO** use thin, rounded SF Symbols to match the weight of the Inter/SF Pro body text.

### Don't
*   **DON'T** use pure #000000 for shadows. It breaks the ethereal, light-filled aesthetic.
*   **DON'T** mix sharp 90-degree corners with squircles. Every element must feel "pebbled" and smooth.
*   **DON'T** stack more than three layers of glass. Excessive nesting leads to "blur-clutter" and reduces legibility.