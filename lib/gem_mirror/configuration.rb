#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-09-18 12:19:06 +0100 (Thu, 18 Sep 2014)
#
#  vim:ts=4:sw=4:et
#
module GemMirror
  module Configuration
    def set_default_configuration
      {}
    end

    def settings configuration = nil
      @settings ||= configuration
    end

    def validate_options options
      validate_file options[:config]
      # step: load any configurations files
      configuration = ( options[:config] ) ? load_configuration_file( options[:config] ) : set_default_configuration
      # step: check we have the validate_options
      raise ArgumentError, "you have not specified any mirrors" unless configuration['mirrors']
      configuration['mirrors'].each_pair do |name,config|
        validate_mirror_configuration name, config
        new_source = GemMirror::Source.new name
        new_source.source = config['source']
        new_source.destination = config['destination']
        new_source.threads = config['threads'] || configuration['threads'] || 1
        new_source.remove_deleted = config['remove_deleted'] || configuration['remove_deleted'] || true
        sources[name] = new_source
      end
      configuration
    end

    def load_configuration_file filename
      YAML.load(File.read(validate_file(filename)))
    end

    def validate_mirror_configuration name, configuration
      raise ArgumentError, "you have not specified the name of the source" unless name
      raise ArgumentError, "#{name}: you have not specified the source url" unless configuration['source']
      raise ArgumentError, "#{name}: you have not specified the destination directory" unless configuration['destination']
      debug "checking mirror: #{name}, source: #{configuration['source']}, destination: #{configuration['destination']}"
      # step: check the source url is valid
      raise ArgumentError, "#{name}: the source: #{configuration['source']} is not a valid uri" unless uri? configuration['source']
      Dir.mkdir configuration['destination'] unless File.exists? configuration['destination']
      validate_directory configuration['destination'], true
    end
  end
end
