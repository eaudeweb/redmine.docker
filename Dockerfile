FROM redmine:4.2.3-bullseye
LABEL maintainer="<informea@eaudeweb.ro>"


ENV REDMINE_PATH=/usr/src/redmine \
    REDMINE_LOCAL_PATH=/var/local/redmine

# Install dependencies and plugins
RUN apt-get update -q \
 && apt-get install -y --no-install-recommends apt-utils cron unzip netcat-traditional vim curl python3-pip build-essential python3-dev imagemagick\
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && pip3 install --upgrade setuptools \
 && pip3 install wheel \
 && pip3 install PyYAML ruamel.yaml

COPY plugins/* ${REDMINE_LOCAL_PATH}/plugins/

RUN mkdir -p ${REDMINE_LOCAL_PATH}/github \
 && mkdir -p ${REDMINE_LOCAL_PATH}/scripts \
 && mkdir -p ${REDMINE_LOCAL_PATH}/backup \
 && cd ${REDMINE_PATH}/plugins \
 && git clone https://github.com/akiko-pusu/redmine_banner.git \
 && git clone https://github.com/paginagmbh/redmine_silencer.git \
 && git clone https://github.com/rgtk/redmine_impersonate.git \
 && git clone https://github.com/rgtk/redmine_editauthor.git \
 && git clone https://github.com/GEROMAX/redmine_subtask_list_accordion.git \
 && git clone https://github.com/jkraemer/stopwatch.git \
 && unzip -d ${REDMINE_PATH}/plugins -o ${REDMINE_LOCAL_PATH}/plugins/redmine_checklists-3_1_20-light.zip \
 && git clone https://github.com/two-pack/redmine_xlsx_format_issue_exporter.git \
 && unzip -d ${REDMINE_PATH}/plugins -o ${REDMINE_LOCAL_PATH}/plugins/redmine_agile-1_6_2-light.zip \
 && unzip -d ${REDMINE_PATH}/plugins -o ${REDMINE_LOCAL_PATH}/plugins/redmine_people-1_6_1-light.zip \
 && unzip -d ${REDMINE_PATH}/plugins -o ${REDMINE_LOCAL_PATH}/plugins/redminex-resources-1-2-1-DEMO_UNZIP_ME_FIRST.zip \
 && cd ${REDMINE_PATH} \
 && gem install bundler --pre \
 && chown -R redmine:redmine ${REDMINE_PATH} ${REDMINE_LOCAL_PATH} \
 && unzip -d ${REDMINE_PATH}/public/themes -o ${REDMINE_LOCAL_PATH}/plugins/edw-theme.zip \
 && unzip -d ${REDMINE_PATH}/public/themes -o ${REDMINE_LOCAL_PATH}/plugins/informea-theme.zip

COPY entrypoint.sh scripts/receive_imap.sh scripts/update-repositories.sh scripts/update_configuration.py ${REDMINE_LOCAL_PATH}/scripts/
COPY crontab ${REDMINE_LOCAL_PATH}/

WORKDIR $REDMINE_PATH

ADD patches/allow_watchers_and_contributers_access_to_issues_4.2.2.patch \
    patches/imap_scan_multiple_folders.patch \
    patches/subprojects_query_filter_fix.patch \
    ${REDMINE_PATH}/

RUN patch -p1 < allow_watchers_and_contributers_access_to_issues_4.2.2.patch \
  && patch -p0 < imap_scan_multiple_folders.patch \
  && patch -p0 < subprojects_query_filter_fix.patch

ENTRYPOINT ["/var/local/redmine/scripts/entrypoint.sh"]

CMD []
