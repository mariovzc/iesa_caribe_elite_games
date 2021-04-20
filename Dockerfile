FROM ruby:2.7

RUN apt-get update -qq && apt-get install -y build-essential

ENV TZ=America/Bogota
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN gem install bundler:1.17.2

ADD Gemfile* $APP_HOME/

RUN bundle install --without development test

ADD . $APP_HOME


CMD ["ruby", "app.rb"]