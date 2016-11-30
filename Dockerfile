FROM ruby:2.3.1-alpine

RUN apk add --no-cache bash nano sqlite sqlite-dev

RUN mkdir -p /app
WORKDIR /app
COPY Gemfile* /app/

RUN apk add --no-cache build-base \
  && bundle install --quiet \
  && apk del build-base

COPY . /app
EXPOSE 4567
CMD ["bundle", "exec", "ruby", "app.rb"]
