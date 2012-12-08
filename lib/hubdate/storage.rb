class Storage
  def self.write_file(contents, destination)
    File.open(destination, "w") do |file|
      file << contents.to_yaml
    end
  end

  def self.clear_files(dir)
    raise StandardError.new("Unable to delete folder.") unless FileUtils.rm_rf(dir)
  end

  def self.make_file(dir, file)
    f = File.new(File.join(dir, file), "w+")

    raise StandardError.new("Unable to make file.") unless f

    f.close
  end

  def self.make_folder(dir)
    folder = FileUtils.mkdir(dir)

    raise StandardError.new("Unable to create directory.") unless folder
  end

  def self.dir_initialized?(dir)
    if File.directory?(dir)
      return true
    else
      return false
    end
  end

  def self.file_initialized?(file)
    if File.exists?(file)
      return true
    else
      return false
    end
  end

  def self.generate_follow
    Storage.make_file(File.join(Dir.home, ".hubdate") , "followers.yaml")
  end

  def self.generate_star
    Storage.make_file(File.join(Dir.home, ".hubdate"), "stargazers.yaml")
  end

  def self.generate_watch
    Storage.make_file(File.join(Dir.home, ".hubdate"), "watchers.yaml")
  end

  def self.generate_files
    Storage.make_folder(File.join(Dir.home, ".hubdate"))

    self.generate_follow
    self.generate_star
    self.generate_watch
  end
end
