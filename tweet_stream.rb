#coding: utf-8
require 'rubygems'
require 'bundler'
require 'json'

Bundler.require

require 'twitter/json_stream'

TWITTER_CONSUMER_KEY       ||= ENV['TWITTER_CONSUMER_KEY']
TWITTER_CONSUMER_SECRET    ||= ENV['TWITTER_CONSUMER_SECRET']
TWITTER_OAUTH_TOKEN        ||= ENV['TWITTER_OAUTH_TOKEN']
TWITTER_OAUTH_TOKEN_SECRET ||= ENV['TWITTER_OAUTH_TOKEN_SECRET']

EventMachine::run {
  stream = Twitter::JSONStream.connect(
    :host => "userstream.twitter.com", 
    :path => "/2/user.json",
    :port => 443,
#    :path => "/1.1/statuses/sample.json",
    :oauth => {
      :consumer_key    => TWITTER_CONSUMER_KEY,
      :consumer_secret => TWITTER_CONSUMER_SECRET,
      :access_key      => TWITTER_OAUTH_TOKEN,
      :access_secret   => TWITTER_OAUTH_TOKEN_SECRET
    },
    :ssl => true
  )

  stream.each_item do |item|
    tweet = JSON.parse(item)
    if tweet.key?("user") 
      screen_name = tweet["user"]["screen_name"]
    end

    text = tweet["text"]

    if screen_name
      $stdout.print "@#{screen_name} #{text}\n"
    end

    $stdout.flush
  end

  stream.on_error do |message|
    $stdout.print "error: #{message}\n"
    $stdout.flush
  end

  stream.on_reconnect do |timeout, retries|
    $stdout.print "reconnecting in: #{timeout} seconds\n"
    $stdout.flush
  end

  stream.on_max_reconnects do |timeout, retries|
    $stdout.print "Failed after #{retries} failed reconnects\n"
    $stdout.flush
  end
}
