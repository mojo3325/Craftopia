## DESIGN STYLE

Briefly: In professional circles, this set of techniques is commonly called Soft UI / Flat 2.0 (and within Apple's ecosystem — simply "new HIG-style macOS / iOS").

In detail:

Why not pure Flat design (2013 style)

There are button background gradients;

There are soft outer shadows — meaning the plane is "elevated".
The original Flat design rejected both of these.

Why not Neumorphism

In Neumorphism, shadows and highlights come FROM the background itself, and the element appears to be "extruded" or "pressed in".

Here the button lies on an independent layer: a separate drop-shadow is visible.

Features that bring it closer to Skeuomorphism, but don't make it one:

Light illusion of volume (gradient + highlight), however without textures, excessive detail, and real "materials".

Key style characteristics (what you're describing):

Large border radii (4–12 px on macOS, 12–20 px on iOS);

Barely noticeable linear gradient (≈ 2–4% brightness difference);

One soft shadow with large blur (2–4 px offset, 8–16 px blur, 8–12% opacity);

White or very light surfaces appear "matte";

Accent blue remains flat (without gradient), to contrast with "cards".

How it's called in different sources

Soft UI (Dribbble, Behance);

Flat 2.0, Semi-flat (Microsoft articles, InVision);

New macOS/iOS HIG style (Apple documentation, since Apple avoids labels);

"Post-Skeuomorphic" or "Modern Minimal Skeuo" — less common in blogs.

When to apply it

Settings panels, modal windows, card grids;

B2B interfaces where hierarchy is needed, but without visual noise;

Any products that want to "look Apple-like", without falling into trashy neumorphism.

How to explain to a client / colleague in one breath
"This is Soft UI (Flat 2.0): minimalist foundation of flat design + barely noticeable gradients and soft shadows, so elements feel tangible but don't overload the interface."

Here's a complete color manual for website/app design in the style you've described — with current corrections for buttons and recommended values for backgrounds, texts, borders, accents.
This set can be used as a color table (Design Tokens) for Figma, CSS, Tailwind, Sass, and other systems.

***

## Basic Background Colors

- **Main background:** `#F5F6F8`
- **White container (base surface):** `#FFFFFF`
- **Secondary areas background:** `#FAFBFC`

***

## Borders and Dividers

- **Main containers border:** `#E3E6EB`
- **Cards and modals border:** `#EAEAEA`
- **Primary button border:** `#2D5DB7`
- **Secondary button border:** `#EAEAEA`

***

## Shadows (Box-shadow)

- **Containers shadow:** `0 4px 24px rgba(30, 41, 59, 0.08)`
- **Primary button shadow:** `0 2px 8px rgba(32, 108, 229, 0.12)`
- **Secondary button shadow:** `0 2px 6px rgba(30, 41, 59, 0.06)`

***

## Main Accent and Status Colors

- **Primary accent (Primary Blue):** `#186DEE`
- **Bright accent (Accent Blue):** `#1B77FD`
- **Switch On:** `#3D78F2`
- **Primary button gradient:**
  `linear-gradient(180deg, #6DA4FB 0%, #206CE5 100%)`
- **Secondary button gradient:**
  `linear-gradient(180deg, #FFF 0%, #ECECEC 100%)`

***

## Texts

- **Main headings text:** `#131B22`
- **Regular text:** `#4B5669`
- **Secondary text/placeholder:** `#99A1B3`
- **Primary button text:** `#FFF`
- **Secondary button text:** `#545A62`
- **Disabled text:** `#C2C8D0`

***

## State/Success/Error Colors (Optional)

- **Success green:** `#2ED47A`
- **Error red:** `#F05A5A`
- **Warning orange:** `#EDA23A`
- **Information:** `#46A6FF`
- **Notification/info background:** `#F4F8FE`

***

## Border-radius

- **Buttons:** `border-radius: 10px`
- **Cards:** `border-radius: 14px`
- **Windows/Modals:** `border-radius: 16px`

***

## CSS Variables (for copy-paste)
```css
:root {
  --bg-main: #F5F6F8;
  --bg-surface: #FFFFFF;
  --bg-neutral: #FAFBFC;

  --border-main: #E3E6EB;
  --border-card-modal: #EAEAEA;
  --border-primary-btn: #2D5DB7;
  --border-secondary-btn: #EAEAEA;

  --shadow-main: 0 4px 24px rgba(30, 41, 59, 0.08);
  --shadow-primary-btn: 0 2px 8px rgba(32, 108, 229, 0.12);
  --shadow-secondary-btn: 0 2px 6px rgba(30, 41, 59, 0.06);

  --primary-blue: #186DEE;
  --accent-blue: #1B77FD;
  --switch-on: #3D78F2;

  --gradient-primary-btn: linear-gradient(180deg, #6DA4FB 0%, #206CE5 100%);
  --gradient-secondary-btn: linear-gradient(180deg, #FFF 0%, #ECECEC 100%);

  --text-heading: #131B22;
  --text-main: #4B5669;
  --text-muted: #99A1B3;
  --text-primary-btn: #FFF;
  --text-secondary-btn: #545A62;
  --text-disabled: #C2C8D0;

  --success: #2ED47A;
  --error: #F05A5A;
  --warning: #EDA23A;
  --info: #46A6FF;
  --bg-info: #F4F8FE;
}

/* Border radius — as standard for the entire design */
:root {
  --radius-btn: 10px;
  --radius-card: 14px;
  --radius-modal: 16px;
}
```

***

### General recommendations:
- **Use only transparent/soft shadows**.
- **Minimum saturated colors**, maximum air and smooth transitions.
- **General proportions of roundings and shadows** adhere to a neat, "soft" feel.
- **Text should be clear**, without excessive color saturation.

***
