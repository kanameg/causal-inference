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


# ----------------------------------------
# OVB (Omitted Variable Bias) 脱落変数バイアス
# ----------------------------------------
# 目的変数Yと、介入変数Zに対して相関のある変数を追加する

library("broom")

formula_vec <- c(spend ~ treatment + recency + channel, # モデルA
                 spend ~ treatment + recency + channel + history, # モデルB
                 history ~ treatment + channel + recency) # モデルC

names(formula_vec) <- paste("reg", LETTERS[1:3], sep = "_")

models <- formula_vec %>%
    enframe(name = "model_index", value = "formula")

models_df <- models %>%
    mutate(model = map(.x = formula, .f = lm, data = biased_df)) %>%
    mutate(model_summary = map(.x = model, .f = tidy))

models_df

results_df <- models_df %>%
    mutate(formula = as.character(formula)) %>%
    select(formula, model_index, model_summary) %>%
    unnest(cols = c(model_summary))

treatment_coef <- results_df %>%
    filter(term == "treatment") %>%
    pull(estimate)

history_coef <- results_df %>%
    filter(model_index == "reg_B",
           term == "history") %>%
    pull(estimate)

OVB <- history_coef * treatment_coef[3]
coef_gap <- treatment_coef[1] - treatment_coef[2]

OVB
coef_gap
