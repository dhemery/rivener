require 'nokogiri'
require 'ostruct'

module Rivener
  class Scrivx
    PROJECT_PROPERTIES_MAP = {
      title: 'ProjectTitle',
      abbreviated_title: 'AbbreviatedTitle',
      author_full_name: 'FullName',
      author_last_name: 'LastName',
      author_first_name: 'FirstName'
    }

    def self.scrivx(scrivener_path)
      basename = File.basename(scrivener_path, '.*')
      scrivx_path = File.join(scrivener_path, "#{basename}.scrivx")

      raise "Cannot read SCRIVX file: #{scrivx_path}" unless File.exist? scrivx_path

      File.open(scrivx_path) { |scrivx_file| return Rivener::Scrivx.new(Nokogiri::XML scrivx_file)}
    end

    def self.project(scrivener_path)
      scrivx(scrivener_path).project
    end

    def initialize(scrivx)
      @scrivx = scrivx
    end

    def project
      OpenStruct.new(properties_from_elements(context: project_properties_node, map: PROJECT_PROPERTIES_MAP))
    end

    private

    def project_properties_node
      @scrivx.at_xpath('.//ProjectProperties')
    end

    def properties_from_elements(context:, map:)
      map.inject({}) do |properties, (property, xpath)|
        properties[property] = context.at_xpath(xpath).content
        properties
      end
    end
  end
end
