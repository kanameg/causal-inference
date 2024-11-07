# ----------------------------------------
# 1章 セレクションバイアスとRCT
# ----------------------------------------

# ライブラリの読み込み
library("tidyverse")

# 購買データの読み込み
# from web
# email_df <- read_csv("http://www.minethatdata.com/Kevin_Hillstrom_MineThatData_E-MailAnalytics_DataMiningChallenge_2008.03.20.csv")
# from local
email_df <- read_csv("data/Kevin_Hillstrom_MineThatData_E-MailAnalytics_DataMiningChallenge_2008.03.20.csv")

# 購買データの保存
# write_csv(email_df, file = "./data/Kevin_Hillstrom_MineThatData_E-MailAnalytics_DataMiningChallenge_2008.03.20.csv")

# 女性向けのメールを送信したデータを削除して、男性向けのメールを送信したデータのみを抽出
# 男性向けのメールを送信したデータのtreatmentを1、それ以外を0に設定（介入フラグ）
male_df <- email_df %>%
  filter(segment != "Womens E-Mail") %>%
  mutate(treatment = ifelse(segment == "Mens E-Mail", 1, 0))

# データの確認
male_df %>%
  head()

# RCTデータの保存
write_csv(male_df, file = "./data/male.csv")

# 全体の平均購買率、平均購買、サンプル数
summary <- male_df %>%
  summarise(conversion_rate = mean(conversion),
            spend_mean = mean(spend),
            count = n())
summary

# 介入群と非介入群の平均購買率、平均購買、サンプル数
summary_by_segment <- male_df %>%
  group_by(treatment) %>%
  summarise(conversion_rate = mean(conversion),
            spend_mean = mean(spend),
            count = n())
summary_by_segment

# 介入群 Y^{(1)}
mens_mail_df <- male_df %>%
  filter(treatment == 1) %>%
  pull(spend)

# 非介入群 Y^{(0)}
no_mail_df <- male_df %>%
  filter(treatment == 0) %>%
  pull(spend)

# t検定 (等分散性を仮定)
# 二つの標本の平均値の差の検定
rct_ttest <- t.test(mens_mail_df, no_mail_df, var.equal = TRUE)
rct_ttest

# ----------------------------------------
# バイアスありのデータの作成
# ----------------------------------------

# シードを固定
set.seed(1)

# サンプル量の変更
obs_rate_c <- 0.5
obs_rate_t <- 0.5

# バイアスのあるデータの作成
biased_df <- male_df %>%
  mutate(
    obs_rate_c = if_else(
      # 以下の条件(昨年の購買額300より大きい または、購入からの経過月数が6より小さい、または接触チャネルが複数)を
      # 満たす場合はobs_rate_cを0.5に設定、それ以外は1に設定
      (history > 300) | (recency < 6) | (channel == "Mulichannel"),
        obs_rate_c, 1),
    obs_rate_t = if_else(
      # 以下の条件(昨年の購買額300より大きい または、購入からの経過月数が6より小さい、または接触チャネルが複数)を
      # 満たす場合はobs_rate_tを1に設定、それ以外は0.5に設定
      (history > 300) | (recency < 6) | (channel == "Mulichannel"),
        1, obs_rate_t),
    random_number = runif(n = NROW(male_df))) %>%
      filter((treatment == 0 & random_number < obs_rate_c) |
             (treatment == 1 & random_number < obs_rate_t))
biased_df

summary_by_segment_biased <- biased_df %>%
  group_by(treatment) %>%
  summarise(conversion_rate = mean(conversion),
            spend_mean = mean(spend),
            count = n())
summary_by_segment_biased

# 介入群 Y^{(1)}
mens_mail_biased_df <- biased_df %>%
  filter(treatment == 1) %>%
  pull(spend)

# 非介入群 Y^{(0)}
no_mail_biased_df <- biased_df %>%
  filter(treatment == 0) %>%
  pull(spend)

# t検定 (等分散性を仮定)
# 二つの標本の平均値の差の検定
rct_ttest_biased <- t.test(mens_mail_biased_df, no_mail_biased_df, var.equal = TRUE)
rct_ttest_biased

#         Two Sample t-test

# data:  mens_mail_biased_df and no_mail_biased_df
# t = 5.6823, df = 31847, p-value = 1.34e-08
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#  0.6347589 1.3032498
# sample estimates:
# mean of x mean of y 
# 1.5115392 0.5425349

rct_ttest

#         Two Sample t-test

# data:  mens_mail_df and no_mail_df
# t = 5.3001, df = 42611, p-value = 1.163e-07
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#  0.4851384 1.0545160
# sample estimates:
# mean of x mean of y 
# 1.4226165 0.6527894 

biased_df %>%
  select(conversion, spend, random_number, treatment, obs_rate_c, obs_rate_t)



# バイアスありデータの保存
write_csv(biased_df, file = "./data/biased.csv")

