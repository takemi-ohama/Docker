FROM redmine:5.1.4-bookworm

RUN apt update && apt install -y build-essential unzip

RUN mkdir -p /usr/src/redmine/mnt && \
    mv /usr/src/redmine/files /usr/src/redmine/mnt/ && \
    ln -s /usr/src/redmine/mnt/files /usr/src/redmine/files && \
    chown -R redmine /usr/src/redmine/mnt

WORKDIR /usr/src/redmine/plugins
COPY redmine_agile-1_6_9-light.zip /usr/src/redmine/plugins
RUN git clone https://github.com/kontron/redmine_oauth.git && \
    git clone https://github.com/tkusukawa/redmine_work_time.git && \
    git clone https://gitlab.com/bdemirkir/sidebar_hide.git && \
    unzip redmine_agile-1_6_9-light.zip && \
    bundle install --without development test --no-deployment

WORKDIR /usr/src/redmine/public/themes
RUN wget https://github.com/Nitrino/flatly_light_redmine/archive/refs/tags/v0.2.4.zip && \
    unzip v0.2.4.zip

WORKDIR /usr/src/redmine
