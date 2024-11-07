# ----------------------------
# ggplot2の基本的な使い方
# ----------------------------
library("ggplot2")

# アヤメのデータを読み込む
str("iris")

jp_font <- "IPAGothic"

# 散布図をプロット
graph = ggplot(iris, aes(x = Sepal.Width, y = Sepal.Length, color = Species)) +
  xlab("がく片の長さ") + ylab("がく片の幅") +
  theme(text = element_text(family = jp_font)) +
  geom_point()
plot(graph)

# ggsave("Sepal.png", graph)
