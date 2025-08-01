FROM ruby:3.3
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