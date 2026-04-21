# Path to input image
img <- "data-raw/sherlock.png"

# Generate sticker and save to standard location
if (rlang::is_installed("hexSticker")) {
  logo_path <- "data-raw/sherlock_sticker.png"
  s <- suppressWarnings(
    hexSticker::sticker(
      img,
      s_x = 1,
      s_y = 0.75,
      s_width = 0.3,
      s_height = 0.4,
      package = "YouAnalyser",
      p_x = 1,
      p_y = 1.4,
      p_size = 18,
      p_color = "white",
      h_size = 1.2,
      h_fill = yougov_colors[["Red 1"]],
      h_color = "white",
      url = "eguizarrosales.github.io/YouAnalyser/",
      u_size = 3,
      u_color = "white",
      filename = logo_path
    )
  )
  use_logo(logo_path)
}
