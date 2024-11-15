FROM redmine:5.1.4-bookworm

USER redmine

RUN mkdir -p /usr/src/redmine/mnt && \
    mv /usr/src/redmine/files /usr/src/redmine/plugins /usr/src/redmine/public/themes /usr/src/redmine/mnt/ && \
    ln -s /usr/src/redmine/mnt/files /usr/src/redmine/files && \
    ln -s /usr/src/redmine/mnt/plugins /usr/src/redmine/plugins && \
    ln -s /usr/src/redmine/mnt/themes /usr/src/redmine/public/themes

USER root
