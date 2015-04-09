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

    def self.scrivx(path)
      scrivener_path = Pathname(path)
      basename = scrivener_path.basename
      scrivx_path = scrivener_path / basename.sub_ext('.scrivx')

      raise "Cannot read SCRIVX file: #{scrivx_path}" unless scrivx_path.exist?

      scrivx_file = scrivx_path.open
      Rivener::Scrivx.new(path: scrivener_path, scrivx: Nokogiri::XML(scrivx_file))
    end

    def self.project(scrivener_path)
      scrivx(scrivener_path).project
    end

    def initialize(path:, scrivx:)
      @path = Pathname(path)
      @scrivx = scrivx
    end

    def project
      project = OpenStruct.new(properties_from_elements(context: project_properties_node, map: PROJECT_PROPERTIES_MAP))
      project.binder = OpenStruct.new
      project.binder.children = children(context: binder_node, parent: project.binder)
      project.custom_metadata_fields = custom_metadata_fields
      project
    end

    private

    def binder_node
      @scrivx.at_xpath('.//Binder')
    end

    def children(context:, parent:)
      return [] if context.nil?
      context.xpath('./BinderItem').map do |binder_item_node|
        include = binder_item_node.at_xpath('./MetaData/IncludeInCompile')
        id = binder_item_node['ID']
        properties = {
          custom_metadata: custom_metadata(binder_item_node),
          file_path: @path / "Files/Docs/#{id}.rtf",
          id: id,
          include_in_compile?: !include.nil? && include.content == 'Yes',
          notes_path: @path / "Files/Docs/#{id}_notes.rtf",
          parent: parent,
          synopsis_path: @path / "Files/Docs/#{id}_synopsis.txt",
          title: binder_item_node.at_xpath('./Title').content,
          type: binder_item_node['Type'],
        }
        item = OpenStruct.new(properties)
        children_node = binder_item_node.at_xpath('Children')
        item.children = children(context: children_node, parent: item)
        item
      end
    end

    def custom_metadata(item)
      item.xpath('.//MetaDataItem').inject({}) do |fields, field|
        id = field.at_xpath('./FieldID').content
        value = field.at_xpath('./Value').content
        fields[id] = value
        fields
      end
    end

    def custom_metadata_fields
      @scrivx.xpath('.//CustomMetaDataSettings/MetaDataField').inject({}) do |fields, field|
        fields[field['ID']] = field.content
        fields
      end
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
