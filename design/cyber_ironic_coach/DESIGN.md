---
name: Cyber-Ironic Coach
colors:
  surface: '#141218'
  surface-dim: '#141218'
  surface-bright: '#3b383e'
  surface-container-lowest: '#0f0d13'
  surface-container-low: '#1d1b20'
  surface-container: '#211f24'
  surface-container-high: '#2b292f'
  surface-container-highest: '#36343a'
  on-surface: '#e6e0e9'
  on-surface-variant: '#cbc4d2'
  inverse-surface: '#e6e0e9'
  inverse-on-surface: '#322f35'
  outline: '#948e9c'
  outline-variant: '#494551'
  surface-tint: '#cfbcff'
  primary: '#cfbcff'
  on-primary: '#381e72'
  primary-container: '#6750a4'
  on-primary-container: '#e0d2ff'
  inverse-primary: '#6750a4'
  secondary: '#cdc0e9'
  on-secondary: '#342b4b'
  secondary-container: '#4d4465'
  on-secondary-container: '#bfb2da'
  tertiary: '#e7c365'
  on-tertiary: '#3e2e00'
  tertiary-container: '#c9a74d'
  on-tertiary-container: '#503d00'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e9ddff'
  primary-fixed-dim: '#cfbcff'
  on-primary-fixed: '#22005d'
  on-primary-fixed-variant: '#4f378a'
  secondary-fixed: '#e9ddff'
  secondary-fixed-dim: '#cdc0e9'
  on-secondary-fixed: '#1f1635'
  on-secondary-fixed-variant: '#4b4263'
  tertiary-fixed: '#ffdf93'
  tertiary-fixed-dim: '#e7c365'
  on-tertiary-fixed: '#241a00'
  on-tertiary-fixed-variant: '#594400'
  background: '#141218'
  on-background: '#e6e0e9'
  surface-variant: '#36343a'
typography:
  display-lg:
    fontFamily: Space Grotesk
    fontSize: 48px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: 0.05em
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: 0.02em
  body-main:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  technical-mono:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: '1.4'
    letterSpacing: -0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  edge_padding: 24px
  gutter: 16px
  stack_sm: 8px
  stack_md: 20px
  stack_lg: 40px
---

## Brand & Style

This design system manifests as a high-fidelity interface for the "Gıcık" communication coach. It blends the raw, digital aggression of **Y2K Cyberbrutalism** with the precision and restraint of **Linear-grade product polish**. The brand personality is unapologetically Turkish Gen Z: sophisticated yet ironic, urban, and deeply self-aware. 

The aesthetic avoids all organic warmth, opting instead for a "Deep Cosmic" environment where communication is treated as a technical system to be optimized. The emotional response is one of exclusive access—a premium, dark-mode tool for the socially sharp. Visual storytelling relies on typography and chromatic aberrations rather than photography or illustrative fluff.

## Colors

The palette is rooted in a "Dark-Only" philosophy. The foundation is a sequence of deep cosmic purples and blacks that provide a high-contrast stage for vibrant, neon-soaked accents. 

- **The Void:** Primary (#0A0612) and Secondary (#1A0F2E) backgrounds create architectural depth.
- **The Glow:** Instead of traditional shadows, the system uses soft color washes (blobs) of #FF0080 or #CCFF00 at low opacities to suggest light sources.
- **The Hologram:** A 4-step gradient is reserved for the most premium interactions and the signature dot on the 'ı' in the lowercase 'gıcık' logo.

## Typography

The typographic system creates a deliberate tension between technical rigidity and casual subversion. 

1. **Headlines:** Set in **ALL CAPS Space Grotesk Bold** (as a proxy for Eurostile). This evokes a Y2K aerospace and techno-industrial vibe.
2. **Body:** Set in **lowercase Inter** (as a proxy for SF Pro). The forced lowercase reinforces the ironic, Gen Z "too-cool-to-capitalize" digital dialect.
3. **Technical:** **Inter (Mono-spaced variants)** is used for timestamps, debug data, and coaching metrics to simulate a terminal interface.

## Layout & Spacing

This design system utilizes a rigid **Fixed Grid** approach tailored for mobile-first premium experiences. 

- **Margins:** A strict 24px edge padding is maintained across all screens.
- **Rhythm:** Vertical spacing follows a 4px baseline, with 20px used as the primary separator for card groupings.
- **Alignment:** Content is often justified or strictly aligned to the left to emphasize the "brutalist" grid structure, occasionally broken by holographic elements that bleed into the margins.

## Elevation & Depth

Depth is achieved through **Glassmorphism** and light-pollution techniques rather than traditional skeuomorphism.

- **Glass Surfaces:** Elements use an `ultraThinMaterial` style with 70% opacity and a 20px background blur.
- **Borders:** Premium cards and buttons feature a **1-pixel holographic border**. Non-premium elements use a subtle 1px border in #2D1B4E.
- **Shadows:** Dropped shadows are forbidden. Instead, use a "Soft Glow" (Box-shadow with high spread, low opacity, colored with #FF0080 or #CCFF00) to indicate active states or high-priority notifications.

## Shapes

The shape language is "Squircle-adjacent"—highly engineered curves that feel industrial yet comfortable. 

- **Cards:** Defined by a 20px corner radius.
- **Buttons/Inputs:** Defined by a 16px corner radius.
- **Interactive Elements:** Always maintain a consistent stroke weight of 1px for borders.
- **Logo:** The lowercase 'gıcık' must be rendered with high-precision kerning, with the dot on the 'ı' featuring a radial holographic gradient.

## Components

- **Primary Buttons:** 16px radius, background #FF0080 or #CCFF00, text in ALL CAPS Space Grotesk. For ultra-premium actions, use the holographic gradient background with black text.
- **Glass Cards:** 20px radius, 70% opacity #1A0F2E background, 1px holographic border.
- **Inputs:** Lowercase placeholder text, 1px #2D1B4E border, glowing Accent Lime (#CCFF00) border on focus.
- **Chips:** Monospaced lowercase text inside a pill shape with a 1px solid border; no fill.
- **Coach Feedback Triggers:** Technical "debug" moments using SF Mono typography, styled to look like system logs or terminal output.
- **Lists:** Separated by 1px dividers in #2D1B4E, no external padding, ensuring the content hits the 24px edge margin.