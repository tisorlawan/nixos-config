.pragma library

// Theme catalog. Each theme pairs a dark palette and a light palette with the
// same color roles. Theme.qml selects the palette from the ~/.color mode.
// The first theme is the default. ~/.scripts/set-theme applies a theme ID to
// the other apps, and files/cfg/themes/generate.cjs builds their theme files
// from these palettes. Run the generator after a change to this catalog.
//
// Roles:
//   panelBg      bar and popup background
//   panelBorder  popup border
//   text         primary text
//   mutedText    secondary text
//   activeText   focused workspace text, accents, quota bars
//   urgent       errors and urgent workspace fill
//   chipDark     recessed chip fill
//   chipLight    raised chip fill
//   chipBlue     focused or selected chip fill
//   chipGreen    active (not focused) chip fill
//   red, green, yellow, blue, magenta, cyan
//                the theme's terminal colors, for apps that color by meaning
//                (btop graphs, Claude Code diffs). The bar does not use them.
//   browserSeed  optional Brave seed color, in place of panelBg. Brave
//                strengthens the seed's saturation: a #f4fef5 seed gives a
//                #91f799 frame and #f9fbf9 gives #d4e2d4. Set it when panelBg
//                turns out too colorful in Brave.
//
// Where a theme has no tinted background colors, chipBlue and chipGreen mix
// 20% of the theme's blue and green into panelBg.

const themes = [
  {
    // Mocha / Latte.
    id: "catppuccin",
    name: "Catppuccin",
    dark: {
      panelBg: "#1e1e2e", panelBorder: "#45475a",
      text: "#cdd6f4", mutedText: "#7f849c", activeText: "#89b4fa", urgent: "#f38ba8",
      chipDark: "#181825", chipLight: "#313244", chipBlue: "#333c57", chipGreen: "#394545",
      red: "#f38ba8", green: "#a6e3a1", yellow: "#f9e2af", blue: "#89b4fa", magenta: "#f5c2e7", cyan: "#94e2d5"
    },
    light: {
      panelBg: "#eff1f5", panelBorder: "#bcc0cc",
      text: "#4c4f69", mutedText: "#8c8fa1", activeText: "#1e66f5", urgent: "#d20f39",
      chipDark: "#e6e9ef", chipLight: "#ccd0da", chipBlue: "#c5d5f5", chipGreen: "#cce1cd",
      red: "#d20f39", green: "#40a02b", yellow: "#df8e1d", blue: "#1e66f5", magenta: "#ea76cb", cyan: "#179299"
    }
  },
  {
    // Wave / Lotus.
    id: "kanagawa",
    name: "Kanagawa",
    dark: {
      panelBg: "#1f1f28", panelBorder: "#54546d",
      text: "#dcd7ba", mutedText: "#727169", activeText: "#7e9cd8", urgent: "#e46876",
      chipDark: "#16161d", chipLight: "#2a2a37", chipBlue: "#223249", chipGreen: "#2b3328",
      red: "#e46876", green: "#98bb6c", yellow: "#e6c384", blue: "#7e9cd8", magenta: "#957fb8", cyan: "#7aa89f"
    },
    light: {
      panelBg: "#f2ecbc", panelBorder: "#d5cea3",
      text: "#545464", mutedText: "#8a8980", activeText: "#4d699b", urgent: "#c84053",
      chipDark: "#e5ddb0", chipLight: "#dcd5ac", chipBlue: "#c7d7e0", chipGreen: "#b7d0ae",
      red: "#c84053", green: "#6f894e", yellow: "#77713f", blue: "#4d699b", magenta: "#b35b79", cyan: "#597b75"
    }
  },
  {
    // Medium contrast dark / light.
    id: "gruvbox",
    name: "Gruvbox",
    dark: {
      panelBg: "#282828", panelBorder: "#504945",
      text: "#ebdbb2", mutedText: "#928374", activeText: "#83a598", urgent: "#fb4934",
      chipDark: "#1d2021", chipLight: "#3c3836", chipBlue: "#3a413e", chipGreen: "#454528",
      red: "#fb4934", green: "#b8bb26", yellow: "#fabd2f", blue: "#83a598", magenta: "#d3869b", cyan: "#8ec07c"
    },
    light: {
      panelBg: "#fbf1c7", panelBorder: "#d5c4a1",
      text: "#3c3836", mutedText: "#928374", activeText: "#076678", urgent: "#9d0006",
      chipDark: "#f2e5bc", chipLight: "#ebdbb2", chipBlue: "#cad5b7", chipGreen: "#e1d8a2",
      red: "#9d0006", green: "#79740e", yellow: "#b57614", blue: "#076678", magenta: "#8f3f71", cyan: "#427b58"
    }
  },
  {
    // Night / Day.
    id: "tokyonight",
    name: "Tokyo Night",
    dark: {
      panelBg: "#1a1b26", panelBorder: "#414868",
      text: "#c0caf5", mutedText: "#565f89", activeText: "#7aa2f7", urgent: "#f7768e",
      chipDark: "#16161e", chipLight: "#292e42", chipBlue: "#283457", chipGreen: "#20303b",
      red: "#f7768e", green: "#9ece6a", yellow: "#e0af68", blue: "#7aa2f7", magenta: "#bb9af7", cyan: "#7dcfff"
    },
    light: {
      panelBg: "#e1e2e7", panelBorder: "#a8aecb",
      text: "#3760bf", mutedText: "#848cb5", activeText: "#2e7de9", urgent: "#f52a65",
      chipDark: "#d0d5e3", chipLight: "#c4c8da", chipBlue: "#bdcee7", chipGreen: "#c6ccc4",
      red: "#f52a65", green: "#587539", yellow: "#8c6c3e", blue: "#2e7de9", magenta: "#9854f1", cyan: "#007197"
    }
  },
  {
    // Main / Dawn. Pine stands in for blue and foam for green.
    id: "rosepine",
    name: "Rosé Pine",
    dark: {
      panelBg: "#191724", panelBorder: "#403d52",
      text: "#e0def4", mutedText: "#6e6a86", activeText: "#9ccfd8", urgent: "#eb6f92",
      chipDark: "#1f1d2e", chipLight: "#26233a", chipBlue: "#1e2a39", chipGreen: "#333c48",
      red: "#eb6f92", green: "#31748f", yellow: "#f6c177", blue: "#9ccfd8", magenta: "#c4a7e7", cyan: "#ebbcba"
    },
    light: {
      panelBg: "#faf4ed", panelBorder: "#dfdad9",
      text: "#575279", mutedText: "#9893a5", activeText: "#286983", urgent: "#b4637a",
      chipDark: "#fffaf3", chipLight: "#f2e9e1", chipBlue: "#d0d8d8", chipGreen: "#d9e1dd",
      red: "#b4637a", green: "#286983", yellow: "#ea9d34", blue: "#56949f", magenta: "#907aa9", cyan: "#d7827e"
    }
  },
  {
    // Hard contrast dark / medium contrast light.
    id: "everforest",
    name: "Everforest",
    dark: {
      panelBg: "#272e33", panelBorder: "#495156",
      text: "#d3c6aa", mutedText: "#859289", activeText: "#7fbbb3", urgent: "#e67e80",
      chipDark: "#1e2326", chipLight: "#374145", chipBlue: "#384b55", chipGreen: "#3c4841",
      red: "#e67e80", green: "#a7c080", yellow: "#dbbc7f", blue: "#7fbbb3", magenta: "#d699b6", cyan: "#83c092"
    },
    // A green-white background in place of Everforest's cream: the hard light
    // backgrounds (bg0, bg4, bg1, bg3) with their OKLCH hue turned to bg_blue's
    // green (#ecf5ed), at the same lightness and chroma. generate.cjs (omp)
    // and nvim/init.lua use the same ramp. Brave gets a whiter green seed,
    // since panelBg gives it a bright green frame.
    light: {
      panelBg: "#f4fef5", panelBorder: "#dbe9dd", browserSeed: "#f9fbf9",
      text: "#5c6a72", mutedText: "#939f91", activeText: "#3a94c5", urgent: "#f85552",
      chipDark: "#ebf9ec", chipLight: "#e0eee2", chipBlue: "#e9f0e9", chipGreen: "#f0f1d2",
      red: "#f85552", green: "#8da101", yellow: "#dfa000", blue: "#3a94c5", magenta: "#df69ba", cyan: "#35a77c"
    }
  },
  {
    id: "solarized",
    name: "Solarized",
    dark: {
      panelBg: "#002b36", panelBorder: "#586e75",
      text: "#839496", mutedText: "#586e75", activeText: "#268bd2", urgent: "#dc322f",
      chipDark: "#002b36", chipLight: "#073642", chipBlue: "#083e55", chipGreen: "#1b412b",
      red: "#dc322f", green: "#859900", yellow: "#b58900", blue: "#268bd2", magenta: "#d33682", cyan: "#2aa198"
    },
    light: {
      panelBg: "#fdf6e3", panelBorder: "#93a1a1",
      text: "#657b83", mutedText: "#93a1a1", activeText: "#268bd2", urgent: "#dc322f",
      chipDark: "#fdf6e3", chipLight: "#eee8d5", chipBlue: "#d2e1e0", chipGreen: "#e5e3b6",
      red: "#dc322f", green: "#859900", yellow: "#b58900", blue: "#268bd2", magenta: "#d33682", cyan: "#2aa198"
    }
  }
];

// Unknown IDs (empty or stale state file) resolve to the first theme.
function find(id) {
  return themes.find(theme => theme.id === id) || themes[0];
}

// WCAG contrast ratio of two "#rrggbb" colors.
function contrast(a, b) {
  const luminance = hex => {
    const [r, g, b] = [1, 3, 5].map(i => parseInt(hex.slice(i, i + 2), 16) / 255)
      .map(c => c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  };
  const [light, dark] = [luminance(a), luminance(b)].sort((x, y) => y - x);

  return (light + 0.05) / (dark + 0.05);
}

// `amount` (0 to 1) of "#rrggbb" color `a` mixed into `b`.
function mix(a, b, amount) {
  const channel = (hex, i) => parseInt(hex.slice(i, i + 2), 16);

  return "#" + [1, 3, 5]
    .map(i => Math.round(channel(b, i) + (channel(a, i) - channel(b, i)) * amount).toString(16).padStart(2, "0"))
    .join("");
}

// `fg` mixed toward black on light backgrounds, or toward white on dark ones,
// in 1% steps until it reaches `ratio` against every background.
function readable(fg, backgrounds, ratio) {
  const light = backgrounds.every(bg => contrast(bg, "#000000") > contrast(bg, "#ffffff"));
  const target = light ? "#000000" : "#ffffff";

  for (let step = 0; step <= 100; step++) {
    const mixed = mix(target, fg, step / 100);
    if (backgrounds.every(bg => contrast(mixed, bg) >= ratio)) {
      return mixed;
    }
  }

  return target;
}

// Bar colors derived from the palette.
//   focusFill   25% of activeText mixed into panelBg: the focused workspace
//               chip, under bold text.
//   text        palette text, at 7:1 on the panel, every chip fill, and
//               focusFill.
//   activeText  palette activeText, at 4.5:1 on the panel and chipBlue, where
//               it marks quota bars and selections.
//   urgentFill  30% of urgent mixed into panelBg: the urgent workspace chip.
//   urgent      palette urgent, at 4.5:1 on the panel, every chip fill, and
//               urgentFill: the urgent workspace number and alert text.
// Each color moves only as far as needed and keeps the palette's color when
// it already reaches its ratio.
function barColors(palette) {
  const fills = [palette.panelBg, palette.chipDark, palette.chipLight, palette.chipBlue, palette.chipGreen];
  const focusFill = mix(palette.activeText, palette.panelBg, 0.25);
  const urgentFill = mix(palette.urgent, palette.panelBg, 0.3);

  return {
    focusFill,
    text: readable(palette.text, fills.concat([focusFill]), 7),
    activeText: readable(palette.activeText, [palette.panelBg, palette.chipBlue], 4.5),
    urgentFill,
    urgent: readable(palette.urgent, fills.concat([urgentFill]), 4.5)
  };
}
