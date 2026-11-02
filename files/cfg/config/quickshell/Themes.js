.pragma library

// Theme catalog. Each theme pairs a dark palette and a light palette with the
// same color roles. Theme.qml selects the palette from the ~/.color mode.
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
//
// Where a theme has no tinted background colors, chipBlue and chipGreen mix
// 20% of the theme's blue and green into panelBg.

const themes = [
  {
    // The original palettes: Kanagawa-based dark, colors/light.lua light.
    id: "default",
    name: "Default",
    dark: {
      panelBg: "#1f1f28", panelBorder: "#3b4252",
      text: "#dcd7ba", mutedText: "#727169", activeText: "#9cabca", urgent: "#f7768e",
      chipDark: "#1f1f28", chipLight: "#434349", chipBlue: "#223249", chipGreen: "#2b3328"
    },
    light: {
      panelBg: "#fefefe", panelBorder: "#d0d0d0",
      text: "#000000", mutedText: "#8a8a8a", activeText: "#1561b8", urgent: "#c2372c",
      chipDark: "#f0f0f0", chipLight: "#e4e4e4", chipBlue: "#dbe7f8", chipGreen: "#e0efe0"
    }
  },
  {
    // Mocha / Latte.
    id: "catppuccin",
    name: "Catppuccin",
    dark: {
      panelBg: "#1e1e2e", panelBorder: "#45475a",
      text: "#cdd6f4", mutedText: "#7f849c", activeText: "#89b4fa", urgent: "#f38ba8",
      chipDark: "#181825", chipLight: "#313244", chipBlue: "#333c57", chipGreen: "#394545"
    },
    light: {
      panelBg: "#eff1f5", panelBorder: "#bcc0cc",
      text: "#4c4f69", mutedText: "#8c8fa1", activeText: "#1e66f5", urgent: "#d20f39",
      chipDark: "#e6e9ef", chipLight: "#ccd0da", chipBlue: "#c5d5f5", chipGreen: "#cce1cd"
    }
  },
  {
    // Wave / Lotus.
    id: "kanagawa",
    name: "Kanagawa",
    dark: {
      panelBg: "#1f1f28", panelBorder: "#54546d",
      text: "#dcd7ba", mutedText: "#727169", activeText: "#7e9cd8", urgent: "#e46876",
      chipDark: "#16161d", chipLight: "#2a2a37", chipBlue: "#223249", chipGreen: "#2b3328"
    },
    light: {
      panelBg: "#f2ecbc", panelBorder: "#d5cea3",
      text: "#545464", mutedText: "#8a8980", activeText: "#4d699b", urgent: "#c84053",
      chipDark: "#e5ddb0", chipLight: "#dcd5ac", chipBlue: "#c7d7e0", chipGreen: "#b7d0ae"
    }
  },
  {
    // Medium contrast dark / light.
    id: "gruvbox",
    name: "Gruvbox",
    dark: {
      panelBg: "#282828", panelBorder: "#504945",
      text: "#ebdbb2", mutedText: "#928374", activeText: "#83a598", urgent: "#fb4934",
      chipDark: "#1d2021", chipLight: "#3c3836", chipBlue: "#3a413e", chipGreen: "#454528"
    },
    light: {
      panelBg: "#fbf1c7", panelBorder: "#d5c4a1",
      text: "#3c3836", mutedText: "#928374", activeText: "#076678", urgent: "#9d0006",
      chipDark: "#f2e5bc", chipLight: "#ebdbb2", chipBlue: "#cad5b7", chipGreen: "#e1d8a2"
    }
  },
  {
    // Night / Day.
    id: "tokyonight",
    name: "Tokyo Night",
    dark: {
      panelBg: "#1a1b26", panelBorder: "#414868",
      text: "#c0caf5", mutedText: "#565f89", activeText: "#7aa2f7", urgent: "#f7768e",
      chipDark: "#16161e", chipLight: "#292e42", chipBlue: "#283457", chipGreen: "#20303b"
    },
    light: {
      panelBg: "#e1e2e7", panelBorder: "#a8aecb",
      text: "#3760bf", mutedText: "#848cb5", activeText: "#2e7de9", urgent: "#f52a65",
      chipDark: "#d0d5e3", chipLight: "#c4c8da", chipBlue: "#bdcee7", chipGreen: "#c6ccc4"
    }
  },
  {
    // Main / Dawn. Pine stands in for blue and foam for green.
    id: "rosepine",
    name: "Rosé Pine",
    dark: {
      panelBg: "#191724", panelBorder: "#403d52",
      text: "#e0def4", mutedText: "#6e6a86", activeText: "#9ccfd8", urgent: "#eb6f92",
      chipDark: "#1f1d2e", chipLight: "#26233a", chipBlue: "#1e2a39", chipGreen: "#333c48"
    },
    light: {
      panelBg: "#faf4ed", panelBorder: "#dfdad9",
      text: "#575279", mutedText: "#9893a5", activeText: "#286983", urgent: "#b4637a",
      chipDark: "#fffaf3", chipLight: "#f2e9e1", chipBlue: "#d0d8d8", chipGreen: "#d9e1dd"
    }
  },
  {
    // Medium contrast dark / light.
    id: "everforest",
    name: "Everforest",
    dark: {
      panelBg: "#2d353b", panelBorder: "#4f585e",
      text: "#d3c6aa", mutedText: "#859289", activeText: "#7fbbb3", urgent: "#e67e80",
      chipDark: "#232a2e", chipLight: "#3d484d", chipBlue: "#3a515d", chipGreen: "#425047"
    },
    light: {
      panelBg: "#fdf6e3", panelBorder: "#e0dcc7",
      text: "#5c6a72", mutedText: "#939f91", activeText: "#3a94c5", urgent: "#f85552",
      chipDark: "#f4f0d9", chipLight: "#e6e2cc", chipBlue: "#e9f0e9", chipGreen: "#f0f1d2"
    }
  },
  {
    id: "solarized",
    name: "Solarized",
    dark: {
      panelBg: "#002b36", panelBorder: "#586e75",
      text: "#839496", mutedText: "#586e75", activeText: "#268bd2", urgent: "#dc322f",
      chipDark: "#002b36", chipLight: "#073642", chipBlue: "#083e55", chipGreen: "#1b412b"
    },
    light: {
      panelBg: "#fdf6e3", panelBorder: "#93a1a1",
      text: "#657b83", mutedText: "#93a1a1", activeText: "#268bd2", urgent: "#dc322f",
      chipDark: "#fdf6e3", chipLight: "#eee8d5", chipBlue: "#d2e1e0", chipGreen: "#e5e3b6"
    }
  }
];

// Unknown IDs (empty or stale state file) resolve to the first theme.
function find(id) {
  return themes.find(theme => theme.id === id) || themes[0];
}
