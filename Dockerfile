FROM httpd:2.4.57-bullseye

ENV RUBY_VERSION=3.2.2

# Install Shibboleth SP
RUN apt-get update && apt-get install -y \
    libapache2-mod-shib \
    && apt-get clean

# Install Ruby
RUN apt-get update && apt-get install -y \
    wget \
    ruby-build \
    libyaml-dev \
    && apt-get clean

RUN cd ~ && \
   wget https://cache.ruby-lang.org/pub/ruby/3.2/ruby-${RUBY_VERSION}.tar.gz && \
   tar -xvzf ruby-${RUBY_VERSION}.tar.gz && \
   cd ruby-${RUBY_VERSION} && \
   ./configure && \
   make && \
   make install

# Install Phusion Passenger
RUN apt-get update && apt-get install -y \
    dirmngr \
    gnupg \
    apt-transport-https \
    ca-certificates \
    curl && \
    curl https://oss-binaries.phusionpassenger.com/auto-software-signing-gpg-key.txt | gpg --dearmor | tee /etc/apt/trusted.gpg.d/phusion.gpg >/dev/null && \
    sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger bullseye main > /etc/apt/sources.list.d/passenger.list' && \
    apt-get clean

RUN apt-get install -y libapache2-mod-passenger

# Create a user for the web app.
RUN addgroup --gid 9999 app && \
    adduser --uid 9999 --gid 9999 --disabled-password --gecos "Application" app && \
    usermod -L app

# Create an /apps/borrow directory
RUN mkdir -p /apps/borrow && \
    chown --recursive app:app /apps

# Copy the Reciprocal Borrowing source code
COPY  --chown=app:app . /apps/borrow/reciprocal-borrowing

COPY  --chown=app:app . /apps/borrow/reciprocal-borrowing

RUN cd /apps/borrow/reciprocal-borrowing && \
    bundle config set --local without 'development,test' && \
    bundle config set --local path 'vendor/bundle' && \
    bundle install

ENV RAILS_RELATIVE_URL_ROOT=/
ENV SCRIPT_NAME=/

# The following SECRET_KEY_BASE variable is used so that the
# "assets:precompile" command will run run without throwing an error.
# It will have no effect on the application when it is actually run.
ENV SECRET_KEY_BASE=IGNORE_ME
RUN cd /apps/borrow/reciprocal-borrowing && \
    bundle exec rake assets:precompile && \
    cd ..
