class Checker
  def self.check_notifications(connection)
    notifications = Github::User.fetch(connection).notifications.reverse

    notifications.each do |notif|
      TerminalNotifier.notify("#{notif.message}", :title => "#{notif.reason[0] = notif.reason[0].capitalize; notif.reason}: #{notif.type}")
    end
  end

  def self.check_watchers(type, connection)
    watchers_file = File.join(Dir.home, ".hubdate", "stargazers.yaml") if type == :stargazer
    watchers_file = File.join(Dir.home, ".hubdate", "watchers.yaml") if type == :watcher

    watchers = Github::User.fetch(connection).watchers(type)

    begin
      file_watchers = YAML.load_file(watchers_file)
    rescue
      Storage.write_file(watchers, watchers_file)
    end

    if file_watchers != watchers 
      new_gazers = {}

      watchers.each do |repo, gazers|
        added = (gazers - file_watchers[repo]).to_a.flatten

        new_gazers[repo] = added
      end

      new_gazers.each do |repo, logins|
        if logins != []
          case type
          when :stargazer
            action = "Starred"
            message_action = "starred"
          when :watcher
            action = "Now Being Watched"
            message_action = "now watching"
          end
          TerminalNotifier.notify("", :title => "Repository #{action}!", :subtitle => "#{logins.join(", ")} #{message_action} your repository \"#{repo}\"!")
        end
      end

      Storage.write_file(watchers, watchers_file)
    end
  end

  def self.check_followers(connection)
    followers_file = File.join(Dir.home, ".hubdate", "followers.yaml")
    
    followers = Github::User.fetch(connection).followers.map {|follower| follower.login}

    begin
      file_followers = YAML.load_file(followers_file)
    rescue
      Storage.write_file(followers, followers_file)
    end

    if file_followers != followers 
      added = (followers - file_followers).to_a

      added.each do |login|
        TerminalNotifier.notify("", :title => 'New Follower!', :subtitle => "#{login} is now following you!")
      end

      Storage.write_file(followers, followers_file)
    end
  end
end