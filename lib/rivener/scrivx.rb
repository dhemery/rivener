require 'ostruct'

module Rivener
  class Scrivx
    SCRIVENER_PROJECT_NODE = 'ScrivenerProject'
    PROJECT_PROPERTIES_NODE = "#{SCRIVENER_PROJECT_NODE}/ProjectProperties"

    PROJECT_PROPERTIES_MAP = {
      context: PROJECT_PROPERTIES_NODE,
      items: {
        title: './ProjectTitle',
        abbreviated_title: './AbbreviatedTitle',
        author_full_name: './FullName',
        author_last_name: './LastName',
        author_first_name: './FirstName'
      }
    }

    def initialize(xml)
      @xml = xml
    end

    def project
      OpenStruct.new(mapped_content(PROJECT_PROPERTIES_MAP))
    end

    private

    def mapped_content(content_map)
      context = @xml.at_xpath(content_map[:context])
      content_map[:items].inject({}) do |memo, (k,v)|
        memo[k] = context.at_xpath(v).content
        memo
      end
    end
  end
end
