# --- STAGE 1: BUILD THEME ---
FROM node:lts AS theme_builder

RUN apt-get update && apt-get install -y git --no-install-recommends && rm -rf /var/lib/apt/lists/*

WORKDIR /theme
RUN git clone --depth 1 -b redmine-6.x https://github.com/gagnieray/opale.git
WORKDIR /theme/opale
RUN npm install
# inject custom styles in application.scss
COPY theme /edw
RUN cp -r /edw/sass/ /theme/opale/src
RUN sed -i '1i@use "custom-variables";' /theme/opale/src/sass/application.scss
RUN echo '@use "custom" as *;' >> /theme/opale/src/sass/application.scss
RUN npm run build

# --- STAGE 2: BUILD REDMINE ---
FROM redmine:6.1.0-bookworm
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
 && git clone --depth 1 https://github.com/agileware-jp/redmine_banner.git \
 && git clone --depth 1 https://github.com/readyredmine/redmine_silencer \
 && git clone --depth 1 https://github.com/rgtk/redmine_impersonate.git \
 && git clone --depth 1 https://github.com/rgtk/redmine_editauthor.git \
 && git clone --depth 1 -b 5.0.x https://github.com/Loriowar/redmine_issues_tree.git \
 && git clone --depth 1 https://github.com/jkraemer/stopwatch.git \
 && git clone --depth 1 https://github.com/two-pack/redmine_xlsx_format_issue_exporter.git \
 && git clone --depth 1 https://github.com/mikitex70/redmine_drawio.git \
 && git clone --depth 1 https://github.com/alphanodes/redmine_lightbox \
 && git clone --depth 1 -b 6.1-extended_watchers https://github.com/maxrossello/redmine_extended_watchers.git \
 && git clone --depth 1 https://github.com:/jperelli/Redmine-Periodic-Task.git periodictask \
 && git clone --depth 1 https://github.com/sk-ys/redmine_issue_hierarchy_filter.git \
 && git clone --depth 1 https://github.com/noshutdown-ru/vault.git \
 && unzip -d ${REDMINE_PATH}/plugins -o ${REDMINE_LOCAL_PATH}/plugins/redmine_agile-1_6_12-light.zip \
 && unzip -d ${REDMINE_PATH}/plugins -o ${REDMINE_LOCAL_PATH}/plugins/redmine_checklists-4_0_0-light.zip \
 && unzip -d ${REDMINE_PATH}/plugins -o ${REDMINE_LOCAL_PATH}/plugins/redmine_favorite_projects-2_1_5-light.zip

# add theme
COPY --from=theme_builder /edw/favicon ${REDMINE_PATH}/themes/EdW/favicon
COPY --from=theme_builder /theme/opale/plugins ${REDMINE_PATH}/themes/EdW/plugins
COPY --from=theme_builder /theme/opale/stylesheets ${REDMINE_PATH}/themes/EdW/stylesheets
COPY --from=theme_builder /theme/opale/webfonts ${REDMINE_PATH}/themes/EdW/webfonts

RUN chown -R redmine:redmine ${REDMINE_PATH} && chown -R redmine:redmine ${REDMINE_LOCAL_PATH}

COPY entrypoint.sh \
     scripts/receive_imap.sh \
     scripts/update-repositories.sh \
     scripts/update_configuration.py \
     scripts/send_reminders.sh \
     scripts/check_periodictasks.sh \
     ${REDMINE_LOCAL_PATH}/scripts/

COPY crontab ${REDMINE_LOCAL_PATH}/
COPY Gemfile.local ${REDMINE_PATH}/
COPY scripts/email_oauth.rake ${REDMINE_PATH}/lib/tasks/

WORKDIR ${REDMINE_PATH}

ADD patches/imap_scan_multiple_folders.patch \
    patches/more_project_from_receiver_addresses.patch \
    patches/subprojects_query_filter_fix.patch \
    patches/notification_prefs_higher_prio.diff \
    # https://www.redmine.org/issues/29321
    patches/move_watchers_to_issues_content_area.diff \
    ${REDMINE_PATH}/

RUN patch -p0 < imap_scan_multiple_folders.patch
RUN patch -p0 < more_project_from_receiver_addresses.patch
RUN patch -p0 < subprojects_query_filter_fix.patch
RUN patch -p0 < move_watchers_to_issues_content_area.diff
RUN patch -p1 < notification_prefs_higher_prio.diff

RUN gosu redmine bundle install

ENTRYPOINT ["/var/local/redmine/scripts/entrypoint.sh"]

CMD []
