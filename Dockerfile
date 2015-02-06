FROM debian:jessie

ENV RUBY_BUILD autoconf bison build-essential git libffi-dev libgdbm-dev libgdbm3 libncurses5-dev libreadline6-dev libssl-dev libyaml-dev wget zlib1g-dev
ENV RUBY_RUN openssl libyaml-0-2
ENV RUBY_VERSION 2.2.0

RUN apt-get update -y && apt-get install -y $RUBY_BUILD $RUBY_RUN --no-install-recommends

RUN  wget -qO - http://cache.ruby-lang.org/pub/ruby/2.2/ruby-$RUBY_VERSION.tar.bz2 | tar -xj && \
  cd ruby-$RUBY_VERSION && \
  ./configure --disable-install-doc --prefix=/opt/ruby-$RUBY_VERSION && \
  make && \
  make install && \
  ln -s /opt/ruby-$RUBY_VERSION/bin/ruby /usr/local/bin && \
  ln -s /opt/ruby-$RUBY_VERSION/bin/gem /usr/local/bin && \
  ln -s /opt/ruby-$RUBY_VERSION/bin/rake /usr/local/bin && \
  cd .. && rm -rf ruby-$RUBY_VERSION

COPY . /app

RUN gem install bundler && \
  ln -s /opt/ruby-$RUBY_VERSION/bin/bundle /usr/local/bin && \
  cd /app && \
  bundle install --binstubs --path vendor/bundle

RUN apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  apt-get purge -y --auto-remove $RUBY_BUILD

EXPOSE 9292
WORKDIR /app
ENTRYPOINT ["bin/rackup", "--host", "0.0.0.0"]
