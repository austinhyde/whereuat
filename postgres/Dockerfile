# Adopted from https://github.com/walm/docker-pgtap/blob/master/Dockerfile
FROM mdillon/postgis

COPY ./test.sh ./build.sh ./build_and_test.sh /
RUN chmod +x /test.sh /build.sh /build_and_test.sh

# make sure postgis stuff runs first
RUN mv /docker-entrypoint-initdb.d/postgis.sh /docker-entrypoint-initdb.d/0000_postgis.sh

RUN apt-get -qq update \
    && apt-get -qq install -y build-essential git-core libv8-dev curl postgresql-server-dev-$PG_MAJOR inotify-tools bc \
    && rm -rf /var/lib/apt/lists/*

# install plv8
ENV PLV8_BRANCH r1.4
RUN cd /tmp && git clone -b $PLV8_BRANCH https://github.com/plv8/plv8.git \
    && cd /tmp/plv8 \
    && make all install

# install pg_prove
RUN curl -LO http://xrl.us/cpanm \
    && chmod +x cpanm \
    && ./cpanm TAP::Parser::SourceHandler::pgTAP

# install pgtap
ENV PGTAP_VERSION v0.95.0
RUN git clone git://github.com/theory/pgtap.git \
    && cd pgtap && git checkout tags/$PGTAP_VERSION \
    && make

# bonus goodies: add some test watching capabilities
RUN curl -sL https://raw.githubusercontent.com/tartley/rerun2/master/rerun > /usr/local/bin/rerun && \
    chmod +x /usr/local/bin/rerun
