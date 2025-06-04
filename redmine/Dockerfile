FROM redmine:5.1.4-bookworm

RUN apt update && apt install -y build-essential unzip

USER redmine

RUN mkdir -p /usr/src/redmine/mnt && \
    mv /usr/src/redmine/files /usr/src/redmine/mnt/ && \
    ln -s /usr/src/redmine/mnt/files /usr/src/redmine/files

WORKDIR /usr/src/redmine/plugins
COPY redmine_agile-1_6_9-pro.zip /usr/src/redmine/plugins
RUN git clone https://github.com/kontron/redmine_oauth.git && \
    git clone https://github.com/tkusukawa/redmine_work_time.git && \
    git clone https://github.com/haru/redmine_theme_changer.git && \
    git clone https://github.com/suer/redmine_absolute_dates.git && \
    unzip redmine_agile-1_6_9-pro.zip && \
    bundle install --without development test --no-deployment

WORKDIR /usr/src/redmine/public/themes
COPY redminecrm_theme-1_2_0.zip /usr/src/redmine/public/themes

RUN git clone https://github.com/Nitrino/flatly_light_redmine.git && \
    git clone https://github.com/tomy-shen/TW-Style.git && \
    unzip redminecrm_theme-1_2_0.zip
COPY redmine-tw.png /usr/src/redmine/public/themes/TW-Style/stylesheets/icons/redmine-tw.png

USER root
WORKDIR /usr/src/redmine

