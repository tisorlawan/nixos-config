foreground {{ foreground }}
background {{ background }}
selection_foreground {{ selection_foreground }}
selection_background {{ selection_background }}

cursor {{ bright_foreground }}
cursor_text_color {{ background }}

# See-through in dark mode, like Tern, and opaque in light mode. Dynamic
# opacity lets a reload change it in running windows, which kitty allows only
# when the option is on from launch.
background_opacity {{ background_opacity }}
dynamic_background_opacity yes

active_border_color {{ accent }}
# Monochrome tabs. The active tab inverts the text colors, and kitty.conf
# draws its title in bold.
active_tab_foreground {{ background }}
active_tab_background {{ foreground }}
inactive_tab_foreground {{ foreground }}
inactive_tab_background {{ lighter_background }}

color0 {{ background }}
color1 {{ red }}
color2 {{ green }}
color3 {{ yellow }}
color4 {{ blue }}
color5 {{ magenta }}
color6 {{ cyan }}
color7 {{ foreground }}
color8 {{ muted }}
color9 {{ bright_red }}
color10 {{ bright_green }}
color11 {{ bright_yellow }}
color12 {{ bright_blue }}
color13 {{ bright_magenta }}
color14 {{ bright_cyan }}
color15 {{ bright_foreground }}
