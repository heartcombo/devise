VERSION 0.7

# This allows one to change the running Ruby version with:
#
# `earthly --allow-privileged +test --EARTHLY_RUBY_VERSION=2.7`
ARG --global EARTHLY_RUBY_VERSION=3.3
ARG --global BUNDLER_VERSION=2.4.5

FROM ruby:$EARTHLY_RUBY_VERSION
WORKDIR /gem

deps:
    # No need to keep a single `RUN` here since this target uses `SAVE ARTIFACT`
    # which means there's no Docker image created here.
    RUN apt update \
        && apt install --yes \
                       --no-install-recommends \
                       build-essential \
                       git \
        && mkdir /gems \
        && git clone https://github.com/Pharmony/warden.git /gems/warden \
        && cd /gems/warden \
        && git checkout features/support-multiple-messages \
        && gem install bundler:${BUNDLER_VERSION}

    COPY Gemfile /gem/Gemfile
    COPY Gemfile.lock /gem/Gemfile.lock
    COPY *.gemspec /gem
    COPY lib/devise/version.rb /gem/lib/devise/version.rb

    RUN bundle install --jobs $(nproc)

    SAVE ARTIFACT /gems git-gems
    SAVE ARTIFACT /usr/local/bundle bundler
    SAVE ARTIFACT /gem/Gemfile Gemfile
    SAVE ARTIFACT /gem/Gemfile.lock Gemfile.lock

dev:
    RUN apt update \
        && apt install --yes \
                       --no-install-recommends \
                       git \
        && gem install bundler:${BUNDLER_VERSION}

    # Import cached gems
    COPY +deps/git-gems /gems
    COPY +deps/bundler /usr/local/bundle
    COPY +deps/Gemfile /gem/Gemfile
    COPY +deps/Gemfile.lock /gem/Gemfile.lock

    # Import gem files
    FOR gem_folder IN app config lib test *.gemspec Rakefile
        COPY $gem_folder /gem/$gem_folder
    END

    ENTRYPOINT ["bundle", "exec"]
    CMD ["rake"]

    # Run `earthly +dev` in order to get the Docker image exported to your
    # Docker images.
    SAVE IMAGE heartcombo/devise:latest

#
# This target runs the test suite.
#
# On you local machine you would likely use `docker compose run --rm gem`
# instead, avoiding to refresh the Docker image which takes some seconds.
#
# Use the following command in order to run the tests suite:
# earthly --allow-privileged +test [--TEST_COMMAND="rake test TEST=test/test_foobar.rb"]
#
# See the above `EARTHLY_RUBY_VERSION` variable.
test:
    FROM earthly/dind:alpine

    COPY docker-compose-earthly.yml ./docker-compose.yml

    # Optionnal argument in the case you'd like to run something else than
    # `rake test`
    ARG TEST_COMMAND

    # Creates a temporary Docker image using the output from the +dev target,
    # that will be used within the `WITH DOCKER ... END` block only.
    WITH DOCKER --load heartcombo/devise:latest=+dev
        RUN docker-compose run --rm gem $TEST_COMMAND
    END
