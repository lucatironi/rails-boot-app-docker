ARG RUBY_VERSION=3.3.0

#####################################################################
# Stage 1: Install gems and precompile assets.
#####################################################################
FROM ruby:$RUBY_VERSION-alpine AS build

ENV APP_DIR='/rails'
ENV BUNDLE_PATH='/bundle'
WORKDIR $APP_DIR

RUN mkdir "${BUNDLE_PATH}" && chmod -R ugo+rwt "${BUNDLE_PATH}"
VOLUME "${BUNDLE_PATH}"

# Install necessary packages to build gems
RUN apk add --no-cache nodejs tzdata postgresql-dev build-base

# Install gems into the vendor/bundle directory in the workspace.
COPY Gemfile Gemfile.lock "${APP_DIR}"
RUN bundle config set path "${BUNDLE_PATH}" \
  && bundle install --jobs 4 --retry 3 \
  && rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git \
  && find "${BUNDLE_PATH}"/ruby/*/gems/ -name "*.c" -delete \
  && find "${BUNDLE_PATH}"/ruby/*/gems/ -name "*.o" -delete

COPY . $APP_DIR

#####################################################################
# Stage 2: Copy gems and assets from build stage and finalize image.
#####################################################################
FROM ruby:$RUBY_VERSION-alpine

ENV APP_DIR='/rails'
ENV BUNDLE_PATH='/bundle'
WORKDIR $APP_DIR

# Install necessary dependencies required to run the Rails application.
RUN apk add --no-cache tzdata postgresql

# Copy everything from the build stage, including gems
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build "${APP_DIR}" "${APP_DIR}"

# Ensure binding is always 0.0.0.0, even in development, to access server from outside container
ENV BINDING="0.0.0.0"

# Overwrite ruby image's entrypoint to provide open cli
ENTRYPOINT [""]