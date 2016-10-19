require 'rubygems'
require 'json'
require 'pp'

json = File.read('glue.cpp.json')
config = JSON.parse(json)

begin
  glue_cpp = File.open(config["output"], 'w')

  config["input"]["includes"].each do |name|
    begin
      include_file = File.open(name, 'r')
      glue_cpp.puts "// #{name}"
      include_file.each_line do |line|
        glue_cpp.puts line
      end
      include_file.close
    rescue Exception => e
      puts e.message
    end
  end

  glue_cpp.puts "namespace MiNodeBinding \{"

  config["input"]["yotta_modules"].each do |package|
    package["files"].each do |name|
      file_name = "yotta_modules/#{package["name"]}/#{name}"

      begin
        input_file = File.open(file_name, 'r')
        glue_cpp.puts "  // #{file_name}"
        input_file.each_line do |line|
          unless /^\s*#include/ =~ line
            tab = "  "
            if /^\s*$/ =~ line
              tab = ""
            end
            glue_cpp.puts "#{tab}#{line}"
          end
        end
        input_file.close
      rescue Exception => e
        puts e.message
      end
    end
  end

  config["input"]["workspace"].each do |name|

    begin
      workspace_file = File.open(name, 'r')
      glue_cpp.puts "// #{name}"
      workspace_file.each_line do |line|
        tab = "  "
        if /^\s*$/ =~ line
          tab = ""
        end
        glue_cpp.puts "#{tab}#{line}"
      end
      workspace_file.close
    rescue Exception => e
      puts e.message
    end


  end

  glue_cpp.puts "\}"

  glue_cpp.close
rescue Exception => e
  puts e.message
end
