Puppet::Type.type(:mysql_database).provide(:mysql) do
  desc "Manages MySQL database."

  defaultfor :kernel => 'Linux'

  optional_commands :mysql      => 'mysql'
  optional_commands :mysqladmin => 'mysqladmin'

  def self.defaults_file
    if File.file?("#{Facter.value(:root_home)}/.my.cnf")
      "--defaults-file=#{Facter.value(:root_home)}/.my.cnf"
    else
      nil
    end
  end

  def defaults_file
    self.class.defaults_file
  end

  def self.instances
    mysql([defaults_file, '-NBe', "show databases"].compact).split("\n").collect do |name|
      new(:name => name)
    end
  end

  def create
    mysql([defaults_file, '-NBe', "create database `#{@resource[:name]}`"].compact)
  end

  def destroy
    mysqladmin([defaults_file, '-f', 'drop', @resource[:name]].compact)
  end

  def exists?
    begin
      mysql([defaults_file, '-NBe', "show databases"].compact).match(/^#{@resource[:name]}$/)
    rescue => e
      debug(e.message)
      return nil
    end
  end

end
