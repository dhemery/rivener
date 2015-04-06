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

    def initialize(xml)
      @xml = xml
    end

    def project
      OpenStruct.new(properties_from_elements(context: project_properties_node, map: PROJECT_PROPERTIES_MAP))
    end

    private

    def project_properties_node
      @xml.at_xpath('.//ProjectProperties')
    end

    def properties_from_elements(context:, map:)
      map.inject({}) do |properties, (property, xpath)|
        properties[property] = context.at_xpath(xpath).content
        properties
      end
    end
  end
end
