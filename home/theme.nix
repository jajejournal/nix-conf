# Tema único: negro puro + acentos Material Ocean. Cambia aquí y cambia todo.
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

  font = { mono = "JetBrainsMono Nerd Font"; ui = "Inter"; size = 10; };

  # Iconos Nerd Font por código unicode (ej: icon "f028")
  icon = code: builtins.fromJSON ''"\u${code}"'';
}
