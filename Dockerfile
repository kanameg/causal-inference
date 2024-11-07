ARG R_VERSION=4.4.0
FROM rocker/rstudio:${R_VERSION}

# 日本語環境の設定
ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8
RUN sed -i '$d' /etc/locale.gen \
    && echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen ja_JP.UTF-8 \
    && /usr/sbin/update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"
RUN /bin/bash -c "source /etc/default/locale"
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# 日本語フォントのインストール
RUN apt-get update && apt-get install -y \
    fonts-ipaexfont \
    fonts-noto-cjk && rm -rf /var/lib/apt/lists/*

# tidyverse に必要なパッケージのインストール
RUN apt-get update && apt-get install -y libxml2-dev \
&& apt-get install -y libfontconfig1-dev \
&& apt-get install -y zlib1g-dev \
&& apt-get install -y libharfbuzz-dev \
&& apt-get install -y libfribidi-dev \
&& apt-get install -y libfreetype6-dev \
&& apt-get install -y libpng-dev \
&& apt-get install -y libjpeg-dev \
&& apt-get install -y libtiff5-dev \
&& rm -rf /var/lib/apt/lists/*

# R パッケージのインストール
RUN Rscript -e "install.packages(c('tidyverse', 'languageserver'))"
