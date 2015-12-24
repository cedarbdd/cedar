class Shell

  def self.run(cmd, logfile = nil)
    puts "#{green}==>#{clear} #{cmd}"
    original_cmd = cmd
    if logfile
      logfile = output_file(logfile)
      cmd = "export > #{logfile}; (#{cmd}) 2>&1 >> #{logfile}; test ${PIPESTATUS[0]} -eq 0"
    end
    system(cmd) or begin
      cmd_msg = "[#{red}Failed#{clear}] Command: #{original_cmd}"
      if logfile
        raise Exception.new <<EOF
#{File.read(logfile)}
#{cmd_msg}
[#{red}Failed#{clear}] Also logged to: #{logfile}

EOF
      else
        raise Exception.new <<EOF
#{cmd_msg}

EOF
      end
    end
  end

  def self.with_env(env_vars)
    old_values = {}
    env_vars.each do |key, new_value|
      old_values[key] = ENV[key]
      ENV[key] = new_value
    end

    env_vars.each { |key, new_value| puts "#{key}=#{new_value}" }
    begin
      yield
    ensure
      env_vars.each_key do |key|
        ENV[key] = old_values[key]
      end
    end
  end

  def self.fold(name)
    name = name.gsub(/[^A-Za-z0-9.-]/, '')
    puts "travis_fold:start:#{name}" if ENV['TRAVIS']
    result = yield(self)
    puts "travis_fold:end:#{name}" if ENV['TRAVIS']
    result
  end

  def self.output_file(target)
    output_dir = if ENV['IS_CI_BOX']
                   ENV['CC_BUILD_ARTIFACTS']
                 else
                   Dir.mkdir(BUILD_DIR) unless File.exists?(BUILD_DIR)
                   BUILD_DIR
                 end

    File.join(output_dir, target)
  end

  private
  def self.green ; "\033[32m" end
  def self.red   ; "\033[31m" end
  def self.clear ; "\033[0m"  end
end
