#!/usr/bin/env node
// Build the app theme files that ~/.scripts/set-theme installs.
//
// t3code/<id>.json  one T3 Code theme per catalog entry, from the Quickshell
//                   palettes in Themes.js (dark palette plus a light variant).
// omp/<name>.json   omp themes for catalog entries without an omp built-in.
//                   Each one reuses the layout of omp's built-in Catppuccin
//                   theme and replaces its palette.
// rofi/<id>-<mode>.rasi
//                   the three colors of config/rofi/config.rasi, from the
//                   Quickshell palettes.
// mako/<id>-<mode>.conf
//                   mako's global colors, from the Quickshell palettes.
//                   ~/.scripts/theme-colors puts one before config/mako/base.
// brave/<id>-<mode>.color
//                   the Brave theme seed: the palette's browserSeed, or
//                   panelBg without one, as six lowercase hex digits. Brave
//                   derives its palette from it.
// hypr/<id>-<mode>.conf, btop/<id>-<mode>.theme, claude/<id>-<mode>.json,
// kitty/<id>-<mode>.conf
//                   templates/*.tpl rendered with the palette. The templates
//                   are Omarchy's (github.com/basecamp/omarchy, default/themed/),
//                   except that claude.json.tpl names the theme with {{ name }}
//                   and kitty.conf.tpl draws monochrome tabs: the active
//                   one inverts foreground and background, and inactive ones
//                   put foreground on lighter_background.
//
// Run with `node files/cfg/themes/generate.cjs` after a change to Themes.js or
// to the palettes below. Reading omp's Catppuccin layout needs omp installed.

const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const here = __dirname;
const themesJs = path.join(here, '../config/quickshell/Themes.js');

function loadCatalog() {
  const source = fs.readFileSync(themesJs, 'utf8').replace(/^\.pragma library\s*$/m, '');
  const context = vm.createContext({});
  vm.runInContext(source + '\nthis.themes = themes;', context);

  return context.themes;
}

function mix(base, top, amount) {
  const channels = hex => [1, 3, 5].map(i => parseInt(hex.slice(i, i + 2), 16));
  const [a, b] = [channels(base), channels(top)];

  return '#' + a.map((value, i) => Math.round(value + (b[i] - value) * amount).toString(16).padStart(2, '0')).join('');
}

// Map the ten Quickshell color roles onto T3 Code color keys. Keys left out
// (search matches, warnings) keep T3 Code's stock values.
function t3Colors(r) {
  return {
    canvas: r.panelBg,
    chrome: r.panelBg,
    toolbar: r.panelBg,
    toolbarForeground: r.text,
    toolbarBorder: r.panelBorder,
    toolbarControl: r.panelBg,
    toolbarControlForeground: r.text,
    toolbarControlHover: r.chipLight,
    surface: r.panelBg,
    surfaceRaised: r.panelBg,
    surfaceOverlay: r.chipDark,
    text: r.text,
    textMuted: r.mutedText,
    border: r.panelBorder,
    input: r.panelBorder,
    focus: r.activeText,
    accent: r.activeText,
    accentForeground: r.panelBg,
    secondary: r.chipDark,
    secondaryForeground: r.text,
    muted: r.chipDark,
    mutedForeground: r.mutedText,
    placeholder: r.mutedText,
    secondaryLabel: r.mutedText,
    iconMuted: r.mutedText,
    error: r.urgent,
    errorForeground: r.urgent,
    errorSurface: mix(r.panelBg, r.urgent, 0.15),
    update: r.activeText,
    updateForeground: r.activeText,
    updateSurface: r.chipBlue,
    accentSurface: r.chipLight,
    accentSurfaceForeground: r.text,
    messageSurface: r.chipLight,
    messageForeground: r.text,
    messageAction: r.activeText,
    messageActionForeground: r.panelBg,
    messageActionHover: mix(r.activeText, r.text, 0.15),
    codeBackground: r.chipDark,
    codeForeground: r.text,
    sidebar: r.chipDark,
    sidebarForeground: r.text,
    sidebarMutedForeground: r.mutedText,
    sidebarControlSurface: r.chipLight,
    sidebarRowHover: r.chipLight,
    sidebarRowActive: r.chipBlue,
    sidebarRowSelected: r.chipBlue,
    sidebarBorder: r.panelBorder,
    terminalBackground: r.panelBg,
    terminalForeground: r.text,
    terminalCursor: r.text,
    terminalSelection: r.chipBlue,
    terminalScrollbar: r.panelBorder,
    terminalScrollbarHover: r.mutedText
  };
}

function t3Theme(theme) {
  return {
    version: 1,
    name: theme.name,
    appearance: 'dark',
    colors: t3Colors(theme.dark),
    variants: { light: t3Colors(theme.light) }
  };
}

// omp palettes in the slots of omp's Catppuccin themes. Each value is the
// closest color of the theme's own palette, except Lotus surface1 and surface2,
// which mix lotusWhite0 (#d5cea3) 20% and 40% toward lotusGray2 (#716e61), and
// the Everforest dark mantle and crust (#171b1e), which darken bg_dim.
const ompPalettes = {
  kanagawa: {
    // Wave.
    dark: {
      rosewater: '#d27e99', flamingo: '#e46876', pink: '#d27e99', mauve: '#957fb8',
      red: '#e46876', maroon: '#ff5d62', peach: '#ffa066', yellow: '#e6c384',
      green: '#98bb6c', teal: '#7aa89f', sky: '#7fb4ca', sapphire: '#658594',
      blue: '#7e9cd8', lavender: '#9cabca', text: '#dcd7ba', subtext1: '#c8c093',
      subtext0: '#a6a69c', overlay2: '#938aa9', overlay1: '#727169', overlay0: '#625e5a',
      surface2: '#54546d', surface1: '#363646', surface0: '#2a2a37', base: '#1f1f28',
      mantle: '#1a1a22', crust: '#16161d'
    },
    // Lotus.
    light: {
      rosewater: '#b35b79', flamingo: '#d7474b', pink: '#b35b79', mauve: '#624c83',
      red: '#c84053', maroon: '#d7474b', peach: '#cc6d00', yellow: '#77713f',
      green: '#6f894e', teal: '#597b75', sky: '#4e8ca2', sapphire: '#6693bf',
      blue: '#4d699b', lavender: '#5d57a3', text: '#545464', subtext1: '#43436c',
      subtext0: '#716e61', overlay2: '#716e61', overlay1: '#8a8980', overlay0: '#a09cac',
      surface2: '#ada889', surface1: '#c1bb96', surface0: '#d5cea3', base: '#f2ecbc',
      mantle: '#e5ddb0', crust: '#dcd5ac'
    }
  },
  everforest: {
    // Hard dark shifted down one step, as in Themes.js.
    dark: {
      rosewater: '#e69875', flamingo: '#e67e80', pink: '#d699b6', mauve: '#d699b6',
      red: '#e67e80', maroon: '#e67e80', peach: '#e69875', yellow: '#dbbc7f',
      green: '#a7c080', teal: '#83c092', sky: '#7fbbb3', sapphire: '#7fbbb3',
      blue: '#7fbbb3', lavender: '#9da9a0', text: '#d3c6aa', subtext1: '#d3c6aa',
      subtext0: '#9da9a0', overlay2: '#9da9a0', overlay1: '#859289', overlay0: '#7a8478',
      surface2: '#414b50', surface1: '#374145', surface0: '#2e383c', base: '#1e2326',
      mantle: '#171b1e', crust: '#171b1e'
    },
    // Light, with the green-white background ramp described in Themes.js.
    light: {
      rosewater: '#f57d26', flamingo: '#f85552', pink: '#df69ba', mauve: '#df69ba',
      red: '#f85552', maroon: '#f85552', peach: '#f57d26', yellow: '#dfa000',
      green: '#8da101', teal: '#35a77c', sky: '#3a94c5', sapphire: '#3a94c5',
      blue: '#3a94c5', lavender: '#829181', text: '#5c6a72', subtext1: '#5c6a72',
      subtext0: '#829181', overlay2: '#829181', overlay1: '#939f91', overlay0: '#a6b0a0',
      surface2: '#b6c7b8', surface1: '#dbe9dd', surface0: '#e0eee2', base: '#f4fef5',
      mantle: '#ebf9ec', crust: '#e5f3e7'
    }
  }
};

// Colors that omp's Catppuccin layouts write as literals, and the palette slot
// that replaces each one.
const ompLiteralSlots = {
  '#656881': 'surface2',
  '#3f9e2b': 'green',
  '#c17b19': 'yellow',
  '#e44fbc': 'pink'
};

function ompBuiltins() {
  const bin = fs.realpathSync(path.join(process.env.HOME, '.bun/bin/omp'));
  const file = path.join(path.dirname(bin), '../../pi-tui/src/theme/defaults.json');

  return JSON.parse(fs.readFileSync(file, 'utf8'));
}

function ompTheme(layout, name, palette) {
  const replaceLiterals = value => {
    if (typeof value === 'string' && value.startsWith('#')) {
      const slot = ompLiteralSlots[value.toLowerCase()];

      if (!slot) {
        throw new Error(`Unmapped color ${value} in omp's Catppuccin layout`);
      }

      return slot;
    }

    if (Array.isArray(value)) {
      return value.map(replaceLiterals);
    }

    if (value && typeof value === 'object') {
      return Object.fromEntries(Object.entries(value).map(([key, item]) => [key, replaceLiterals(item)]));
    }

    return value;
  };

  const { name: _builtinName, vars, ...rest } = layout;
  const missing = Object.keys(vars).filter(slot => !(slot in palette));

  if (missing.length > 0) {
    throw new Error(`${name} is missing palette slots: ${missing.join(', ')}`);
  }

  return { name, vars: palette, ...replaceLiterals(rest) };
}

// bg fills the window, fg colors the text, and button fills the selected row.
function rofiColors(theme, mode) {
  const r = theme[mode];

  return [
    `// Generated by files/cfg/themes/generate.cjs: ${theme.name}, ${mode}.`,
    '* {',
    `    bg:     ${r.panelBg};`,
    `    fg:     ${r.text};`,
    `    button: ${r.chipBlue};`,
    '}',
    ''
  ].join('\n');
}

// The border uses the accent so a popup stands out over windows.
function makoColors(theme, mode) {
  const r = theme[mode];

  return [
    `# Generated by files/cfg/themes/generate.cjs: ${theme.name}, ${mode}.`,
    `background-color=${r.panelBg}`,
    `text-color=${r.text}`,
    `border-color=${r.activeText}`,
    `progress-color=over ${r.chipBlue}`,
    ''
  ].join('\n');
}

// Omarchy's template color names, from a palette. Omarchy takes the shades
// from terminal colors (color0, color7, color8, color15), which this catalog
// does not have, so they come from the closest palette roles.
function templateValues(theme, mode) {
  const r = theme[mode];

  return {
    name: `${theme.name} (${mode})`,
    theme_type: mode,
    background: r.panelBg,
    foreground: r.text,
    accent: r.activeText,
    muted: r.mutedText,
    selection: r.chipBlue,
    selection_background: r.chipBlue,
    selection_foreground: r.text,
    lighter_background: r.chipLight,
    dark_foreground: r.mutedText,
    light_foreground: r.text,
    bright_foreground: r.text,
    red: r.red,
    green: r.green,
    yellow: r.yellow,
    blue: r.blue,
    magenta: r.magenta,
    cyan: r.cyan,
    bright_red: r.red,
    bright_green: r.green,
    bright_yellow: r.yellow,
    bright_blue: r.blue,
    bright_magenta: r.magenta,
    bright_cyan: r.cyan
  };
}

// Render {{ name }}, {{ name_strip }} (no "#"), and {{ mix a b N% }}, which
// moves color a N% toward color b, as Omarchy's renderer does.
function render(templateName, values) {
  const template = fs.readFileSync(path.join(here, 'templates', templateName), 'utf8');
  const value = key => {
    if (!(key in values)) {
      throw new Error(`${templateName}: unknown color ${key}`);
    }

    return values[key];
  };

  return template.replace(/\{\{\s*([^}]*?)\s*\}\}/g, (_, token) => {
    const mixToken = token.match(/^mix\s+(\w+)\s+(\w+)\s+(\d+(?:\.\d+)?)%$/);

    if (mixToken) {
      return mix(value(mixToken[1]), value(mixToken[2]), Number(mixToken[3]) / 100);
    }

    if (token.endsWith('_strip')) {
      return value(token.slice(0, -'_strip'.length)).slice(1);
    }

    return value(token);
  });
}

function writeFile(file, contents) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, contents);
}

function writeJson(file, value) {
  writeFile(file, JSON.stringify(value, null, 2) + '\n');
}

function main() {
  const catalog = loadCatalog();

  for (const theme of catalog) {
    writeJson(path.join(here, 't3code', `${theme.id}.json`), t3Theme(theme));

    for (const mode of ['dark', 'light']) {
      writeFile(path.join(here, 'rofi', `${theme.id}-${mode}.rasi`), rofiColors(theme, mode));
      writeFile(path.join(here, 'mako', `${theme.id}-${mode}.conf`), makoColors(theme, mode));
      writeFile(path.join(here, 'brave', `${theme.id}-${mode}.color`), (theme[mode].browserSeed ?? theme[mode].panelBg).slice(1).toLowerCase() + '\n');

      const values = templateValues(theme, mode);
      writeFile(path.join(here, 'hypr', `${theme.id}-${mode}.conf`), render('hyprland.conf.tpl', values));
      writeFile(path.join(here, 'btop', `${theme.id}-${mode}.theme`), render('btop.theme.tpl', values));
      writeFile(path.join(here, 'claude', `${theme.id}-${mode}.json`), render('claude.json.tpl', values));
      writeFile(path.join(here, 'kitty', `${theme.id}-${mode}.conf`), render('kitty.conf.tpl', values));
    }
  }

  const builtins = ompBuiltins();

  for (const [id, modes] of Object.entries(ompPalettes)) {
    if (!catalog.some(theme => theme.id === id)) {
      throw new Error(`omp palette ${id} has no Themes.js entry`);
    }

    for (const [mode, palette] of Object.entries(modes)) {
      const name = `rice-${id}-${mode}`;
      writeJson(path.join(here, 'omp', `${name}.json`), ompTheme(builtins[`${mode}-catppuccin`], name, palette));
    }
  }
}

main();
