FROM ruby:2.3.1-alpine

RUN apk add --no-cache bash nano build-base sqlite sqlite-dev

RUN mkdir -p /app
WORKDIR /app
COPY Gemfile /app/
RUN bundle install --quiet
COPY . /app
EXPOSE 4567
CMD ["bundle", "exec", "ruby", "app.rb"]
