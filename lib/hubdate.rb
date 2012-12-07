require "rubygems"
require "terminal-notifier"

require 'json'
require 'yaml'
require 'net/http'
require 'net/https'
require 'fileutils'

require File.expand_path(File.join(File.dirname(__FILE__), "hubdate", "base"))
require File.expand_path(File.join(File.dirname(__FILE__), "hubdate", "user"))
require File.expand_path(File.join(File.dirname(__FILE__), "hubdate", "repository"))
require File.expand_path(File.join(File.dirname(__FILE__), "hubdate", "notification"))
require File.expand_path(File.join(File.dirname(__FILE__), "hubdate", "connection"))
require File.expand_path(File.join(File.dirname(__FILE__), "hubdate", "storage"))
require File.expand_path(File.join(File.dirname(__FILE__), "hubdate", "checker"))

if !Storage.dir_initialized?(File.join(Dir.home, ".hubdate"))
  Storage.generate_files
else
  Storage.generate_follow if !Storage.file_initialized?(File.join(Dir.home, ".hubdate", "followers.yaml"))
  Storage.generate_star if !Storage.file_initialized?(File.join(Dir.home, ".hubdate", "stargazers.yaml"))
  Storage.generate_watch if !Storage.file_initialized?(File.join(Dir.home, ".hubdate", "watchers.yaml"))
end

connection = Github::Connection.new({:user => "tommyschaefer", :pass => "43v364591226"})

loop do
  Checker.check_notifications(connection)
  Checker.check_followers(connection)
  Checker.check_watchers(:stargazer, connection)
  Checker.check_watchers(:watcher, connection)
  sleep 10
end
