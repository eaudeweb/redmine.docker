FROM redmine:5.1.3-bookworm
LABEL maintainer="<helpdesk@eaudeweb.ro>"


ENV REDMINE_PATH=/usr/src/redmine \
    REDMINE_LOCAL_PATH=/var/local/redmine

# Install dependencies and plugins
RUN apt-get update -q \
 && apt-get install -y --no-install-recommends apt-utils cron unzip netcat-traditional vim curl python3-pip build-essential python3-dev python3-wheel python3-setuptools imagemagick\
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# RUN pip3 install PyYAML "ruamel.yaml<0.18.0"
RUN pip install PyYAML --break-system-packages

COPY plugins/* ${REDMINE_LOCAL_PATH}/plugins/

RUN mkdir -p ${REDMINE_LOCAL_PATH}/github \
 && mkdir -p ${REDMINE_LOCAL_PATH}/scripts \
 && mkdir -p ${REDMINE_LOCAL_PATH}/backup \
 && cd ${REDMINE_PATH}/plugins \
 && git clone https://github.com/agileware-jp/redmine_banner.git \
 && git clone https://github.com/readyredmine/redmine_silencer \
 && git clone https://github.com/rgtk/redmine_impersonate.git \
 && git clone https://github.com/rgtk/redmine_editauthor.git \
 && git clone -b 5.0.x https://github.com/Loriowar/redmine_issues_tree.git \
 && git clone https://github.com/jkraemer/stopwatch.git \
 && git clone https://github.com/two-pack/redmine_xlsx_format_issue_exporter.git \
 && git clone https://github.com/mikitex70/redmine_drawio.git \
 && git clone https://github.com/alphanodes/redmine_lightbox \
 && git clone -b 5.1-extended_watchers https://github.com/maxrossello/redmine_extended_watchers.git \
 && git clone http://github.com:/jperelli/Redmine-Periodic-Task.git periodictask \
 && unzip -d ${REDMINE_PATH}/plugins -o ${REDMINE_LOCAL_PATH}/plugins/redmine_agile-1_6_9-light.zip \
 # && unzip -d ${REDMINE_PATH}/plugins -o ${REDMINE_LOCAL_PATH}/plugins/redmine_people-1_6_6-light.zip \
 # redmine_people conflicts with redmine_extended_watchers
 && unzip -d ${REDMINE_PATH}/plugins -o ${REDMINE_LOCAL_PATH}/plugins/redmine_checklists-3_1_25-light.zip \
 && unzip -d ${REDMINE_PATH}/plugins -o ${REDMINE_LOCAL_PATH}/plugins/redminex-resources-1-2-1.zip \
 && cd ${REDMINE_PATH} \
 && chown -R redmine:redmine ${REDMINE_PATH} ${REDMINE_LOCAL_PATH} \
 && unzip -d ${REDMINE_PATH}/public/themes -o ${REDMINE_LOCAL_PATH}/plugins/edw-theme.zip


COPY entrypoint.sh \
     scripts/receive_imap.sh \
     scripts/update-repositories.sh \
     scripts/update_configuration.py \
     scripts/send_reminders.sh \
     scripts/check_periodictasks.sh \
     ${REDMINE_LOCAL_PATH}/scripts/

COPY crontab ${REDMINE_LOCAL_PATH}/

WORKDIR $REDMINE_PATH

ADD patches/imap_scan_multiple_folders.patch \
    patches/more_project_from_receiver_addresses.patch \
    patches/subprojects_query_filter_fix.patch \
    # https://www.redmine.org/issues/29321
    patches/move_watchers_to_issues_content_area.diff \
    ${REDMINE_PATH}/

RUN patch -p0 < imap_scan_multiple_folders.patch \
&& patch -p0 < more_project_from_receiver_addresses.patch \
&& patch -p0 < subprojects_query_filter_fix.patch \
&& patch -p0 < move_watchers_to_issues_content_area.diff

RUN gosu redmine bundle install

ENTRYPOINT ["/var/local/redmine/scripts/entrypoint.sh"]

CMD []
