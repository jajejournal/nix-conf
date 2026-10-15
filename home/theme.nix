# Single theme: pure black + Material Ocean accents. Change here to change everything.
{
  bg = "#000000";
  bgAlt = "#0a0a0a";
  surface = "#1a1a1a";
  fg = "#eeffff";
  dim = "#546e7a";
  blue = "#82aaff";
  green = "#c3e88d";
  cyan = "#89ddff";
  purple = "#c792ea";
  red = "#f07178";
  orange = "#f78c6c";
  yellow = "#ffcb6b";

  # Single accent color for bar icons and focused window borders
  accent = "#82aaff";

  font = { mono = "JetBrainsMono Nerd Font"; ui = "Inter"; size = 10; };

  # Nerd Font icons by unicode code (e.g. icon "f028")
  icon = code: builtins.fromJSON ''"\u${code}"'';
}
