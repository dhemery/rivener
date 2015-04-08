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
      project = OpenStruct.new(properties_from_elements(context: project_properties_node, map: PROJECT_PROPERTIES_MAP))
      project.binder_items = binder_items(context: binder_node, parent: nil)
      project
    end

    private

    def binder_items(context:, parent:)
      context.xpath('./BinderItem').map do |binder_item_node|
        include = binder_item_node.at_xpath('./MetaData/IncludeInCompile')
        properties = {
          title: binder_item_node.at_xpath('./Title').content,
          id: binder_item_node['ID'],
          include_in_compile: !include.nil? && include.content == 'Yes',
          parent: parent,
          type: binder_item_node['Type']
        }
        binder_item = OpenStruct.new(properties)
        children = binder_item_node.at_xpath('Children')
        binder_item.binder_items = binder_items(context: children, parent: binder_item) unless children.nil?
        binder_item
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
