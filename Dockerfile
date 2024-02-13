# Dockerfile for the generating the Rails application Docker image
#
# To build:
#
# docker build -t docker.lib.umd.edu/reciprocal-borrowing:<VERSION> -f Dockerfile .
#
# where <VERSION> is the Docker image version to create.
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

RUN gem install --no-document passenger

RUN a2enmod passenger

# Create a user for the web app.
RUN addgroup --gid 9999 app && \
    adduser --uid 9999 --gid 9999 --disabled-password --gecos "Application" app && \
    usermod -L app

# Create an /apps/borrow directory
RUN mkdir -p /apps/borrow && \
    chown --recursive app:app /apps

# USER app
# WORKDIR /apps

ENV RAILS_ENV=production

COPY --chown=app:app Gemfile Gemfile.lock /apps/borrow/reciprocal-borrowing/

# Copy the Reciprocal Borrowing source code
COPY  --chown=app:app . /apps/borrow/reciprocal-borrowing

# Copy application start script
COPY --chown=app:app docker_config/app_start.sh /apps/borrow

# Create directory to hold the Shibboleth certificates
RUN mkdir -p /apps/borrow/certs

RUN cd /apps/borrow/reciprocal-borrowing && \
    gem install bundler --version 2.4.17 && \
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

# Expose port 3000 to the Docker host, so we can access it
# from the outside.
EXPOSE 3000

# The main command to run when the container starts.
CMD ["/apps/borrow/app_start.sh"]
