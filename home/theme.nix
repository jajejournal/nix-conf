# Single theme: pure black + Material Ocean accents. Change here to change everything.
{
  bg = "#000000";
  bgAlt = "#0a0a0a";
  surface = "#1a1a1a";
  fg = "#e6edf3";
  dim = "#8b949e";
  blue = "#58a6ff";
  green = "#3fb950";
  cyan = "#56d4dd";
  purple = "#bc8cff";
  red = "#ff7b72";
  orange = "#ffa657";
  yellow = "#e3b341";

  # Single accent color for bar icons and focused window borders
  accent = "#ffffff";

  font = {
    mono = "JetBrainsMono Nerd Font";
    ui = "Inter";
    size = 10;
  };

  # Nerd Font icons by unicode code (e.g. icon "f028")
  icon = code: builtins.fromJSON ''"\u${code}"'';
}
