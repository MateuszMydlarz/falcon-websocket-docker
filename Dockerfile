FROM ruby:3.4.5
MAINTAINER Mydlarz.Mateusz@gmail.com

RUN apt-get update -qq && apt-get install -y build-essential
RUN apt-get update -qq  \
        && apt-get install -y --no-install-recommends apt-utils build-essential ghostscript

WORKDIR .
RUN mkdir /myapp
WORKDIR /myapp

COPY ./Gemfile /myapp
RUN bundle install

COPY ./ /myapp

EXPOSE 8013