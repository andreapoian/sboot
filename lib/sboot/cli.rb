require "thor"
require "sboot"

module Sboot
  class CLI < Thor
    include Thor::Actions

    source_root "#{File.dirname __FILE__}/scaffolds/"

    desc "init [package]",
         "il comando init genera il file di configurazione per il generatore sboot"
    def init(package)
      writer = Sboot::ConfigWriter.new :package => package
      writer.write
    end


    desc "generate [ENV] :entita' :proprieta'",
      "la flag [ENV] accetta come parametri: fullstack(default),api,backend,business,conversion,persistence"
    method_options :env => "fullstack"
    def generate(name, *args)
      #properties = generate_attributes args
      #entity = DomainEntity.new name: domain_names(name)[:name], name_pluralized: domain_names(name)[:name], properties: properties, environment: options[:env]
      editor = Sboot::Editor.new domain_entity(name, generate_attributes(args), options[:env]), "#{ Dir.pwd }/.sbootconf"
      editor.publish :env

=begin
      writer = Sboot::Writer.new :package => package, :name => name.downcase.capitalize, :properties => properties

      if options[:api]
        writer.api
      else
        writer.fullstack unless options[:env]
        writer.fullstack if options[:env] == 'fullstack'
        writer.backend if options[:env] == 'backend'
        writer.business if options[:env] == 'business'
        writer.convertion if options[:env] == 'convertion'
        writer.persistence if options[:env] == 'persistence'
      end
=end

    end

    private

    def domain_names name
      names = {}
      array_of_names = name.split(":")
      if array_of_names.length == 1
        names['name'] = array_of_names[0]
        names['pluralize'] = nil
      else
        names['name'] = array_of_names[0]
        names['pluralize'] = array_of_names[1]
      end
      names
    end

    def generate_attributes args
      properties = []
      args.each do |arg|
        array = arg.split(":")
        if array.length == 1
          name = array[0].downcase
          type = 'String'
        else
          name = array[0].downcase
          if array[1].downcase == 'string' || array[1].downcase == 'text' || array[1].downcase == 'varchar' || array[1].downcase == 'varchar2'
            type = 'String'
          end
          if array[1].downcase == 'number' || array[1].downcase == 'long'
            type = 'Long'
          end
          if array[1].downcase == 'int' || array[1].downcase == 'integer'
            type = 'Integer'
          end
        end
        property = {name: name,type: type}
        properties << property
      end
      properties
    end

    def domain_entity name, properties, environment
      DomainEntity.new name: domain_names(name)[:name], name_pluralized: domain_names(name)[:pluralize], properties: properties, environment: environment
    end
  end
end
