setwd("~/Documents/course_materials/AQM2/")
library(sf)
library(ggplot2)
library(dplyr)
library(rnaturalearth)
library(rnaturalearthdata)


world = ne_countries(scale = "medium", returnclass = "sf")
europe = world %>%
  filter(subregion == "Western Europe" |
    name %in% c("Spain", "Portugal", "Italy", "France"))


p = ggplot(europe) +
  geom_sf() +
  coord_sf(xlim = c(-10, 18), ylim = c(35, 56))
ggsave("slides/img/weurope.pdf", height = 5, width = 5)

nb_queen = poly2nb(europe, queen = TRUE, row.names = europe$name)
w_queen = nb2mat(nb_queen, style = "W", zero.policy = TRUE)


mat = round(nb2mat(nb_queen, style = "W", zero.policy = TRUE), 1)
colnames(mat) = europe$name
rownames(mat) = europe$name

binmat = mat
binmat[binmat>0] = 1

library(igraph)
g = graph_from_adjacency_matrix(binmat, mode="undirected")
pdf("slides/img/weurope_network.pdf")
plot(g)
dev.off()