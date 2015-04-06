require 'ostruct'

module Rivener
  class Scrivx
    def initialize(xml)
      @xml = xml
    end

    def project
      title = @xml.at_css('ProjectTitle').content
      OpenStruct.new(title: title)
    end
  end
end
