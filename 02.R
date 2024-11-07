# ----------------------------------------
# 2章 介入効果を測るための回帰分析
# ----------------------------------------

# ライブラリの読み込み
library("tidyverse")

# ----------------------------------------
# バイアスありデータの回帰分析
# ----------------------------------------
# バイアスあり購買データの読み込み
biased_df <- read_csv("data/biased.csv")

# 回帰分析を実行
biased_lm <- lm(formula = spend ~ treatment + history, data = biased_df)
summary(biased_lm)

library("broom")
biased_lm_coef <- tidy(biased_lm)
biased_lm_coef


# ----------------------------------------
# RCTデータの回帰分析
# ----------------------------------------
male_df <- read_csv("./data/male.csv")

# 回帰分析を実行
rct_lm <- lm(formula = spend ~ treatment, data = male_df)
summary(rct_lm)

rct_lm_coef <- tidy(rct_lm)
rct_lm_coef

# ----------------------------------------
# バイアスありデータの回帰分析
# ----------------------------------------
# 回帰分析を実行
nonrct_lm <- lm(formula = spend ~ treatment, data = biased_df)
summary(nonrct_lm)

nonrct_lm_coef <- tidy(nonrct_lm)
nonrct_lm_coef


# ----------------------------------------
# バイアスありデータの重回帰分析
# ----------------------------------------
nonrct_multi_lm = lm(formula = spend ~ treatment + recency + channel + history, data = biased_df)
summary(nonrct_multi_lm)

nonrct_multi_lm_coef <- tidy(nonrct_multi_lm)
nonrct_multi_lm_coef
