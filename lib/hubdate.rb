require "rubygems"
require "terminal-notifier"

require 'json'
require 'yaml'
require 'net/http'
require 'net/https'
require 'fileutils'

%w[
  base user repository notification connection storage  checker
].each do |file|
  require File.expand_path(File.join(File.dirname(__FILE__), "hubdate", file))
end

def hubdate_dotfile(*paths)
  File.join(*[Dir.home, ".hubdate"] + paths)
end

def run(user, password, time)
  if !Storage.dir_initialized?(hubdate_dotfile)
    Storage.generate_files
  else
    Storage.generate_follow if !Storage.file_initialized?(hubdate_dotfile("followers.yaml"))
    Storage.generate_star if !Storage.file_initialized?(hubdate_dotfile("stargazers.yaml"))
    Storage.generate_watch if !Storage.file_initialized?(hubdate_dotfile("watchers.yaml"))
  end

  connection = Github::Connection.new({:user => user, :pass => password})

  loop do
    Checker.check_notifications(connection)
    Checker.check_followers(connection)
    Checker.check_watchers(:stargazer, connection)
    Checker.check_watchers(:watcher, connection)
    sleep time
  end
end
