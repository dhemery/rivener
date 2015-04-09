require 'nokogiri'
require 'ostruct'
require 'pathname'

module Rivener
  class Scrivx
    attr_reader :path

    PROJECT_PROPERTIES_MAP = {
      title: 'ProjectTitle',
      abbreviated_title: 'AbbreviatedTitle',
      author_full_name: 'FullName',
      author_last_name: 'LastName',
      author_first_name: 'FirstName'
    }

    def self.scrivx(scrivener_path)
      @path = Pathname(scrivener_path)
      basename = @path.basename
      scrivx_path = @path / basename.sub_ext('.scrivx')

      raise "Cannot read SCRIVX file: #{scrivx_path}" unless scrivx_path.exist?

      scrivx_path.open { |scrivx_file| return Rivener::Scrivx.new(Nokogiri::XML scrivx_file)}
    end

    def self.project(scrivener_path)
      scrivx(scrivener_path).project
    end

    def initialize(scrivx)
      @scrivx = scrivx
    end

    def project
      project = OpenStruct.new(properties_from_elements(context: project_properties_node, map: PROJECT_PROPERTIES_MAP))
      project.binder = OpenStruct.new
      project.binder[:children] = children(context: binder_node, parent: project.binder)
      project
    end

    private

    def children(context:, parent:)
      return [] if context.nil?
      context.xpath('./BinderItem').map do |binder_item_node|
        include = binder_item_node.at_xpath('./MetaData/IncludeInCompile')
        properties = {
          id: binder_item_node['ID'],
          include_in_compile?: !include.nil? && include.content == 'Yes',
          parent: parent,
          title: binder_item_node.at_xpath('./Title').content,
          type: binder_item_node['Type'],
        }
        item = OpenStruct.new(properties)
        children_node = binder_item_node.at_xpath('Children')
        item.children = children(context: children_node, parent: item)
        item
      end
    end

    def binder_node
      @scrivx.at_xpath('.//Binder')
    end

    def project_properties_node
      @scrivx.at_xpath('.//ProjectProperties')
    end

    def properties_from_elements(context:, map:)
      map.inject({}) do |properties, (property, xpath)|
        node = context.at_xpath(xpath)
        properties[property] = node.content unless node.nil?
        properties
      end
    end
  end
end
