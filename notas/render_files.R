# ==================== #
# === RENDER FILES === #
# ==================== #

# --- Script by: Paulo Icaro --- #


# ------------------- #
# --- Bibliotecas --- #
# ------------------- #
library(quarto)


# -------------------- #
# --- Renderização --- #
# -------------------- #
files = list.files(path = 'notas/', pattern = '\\.qmd$', ignore.case = TRUE, full.names = TRUE)
files = files[c(1:3)]
formats = c('pdf', 'gfm')

for (i in seq_along(files)){
  for (j in seq_along(formats)){
    quarto_render(input = files[i], output_format = formats[j])
  }
}


# --------------- #
# --- Limpeza --- #
# --------------- #
rm(files, formats, i, j)