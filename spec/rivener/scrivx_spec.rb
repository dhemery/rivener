require 'rivener/scrivx'

require File.expand_path('../../spec_helper', __FILE__)

require 'nokogiri'

describe Rivener::Scrivx do
  let(:scrivx) { Rivener::Scrivx.new(doc) }
  let(:doc) { Nokogiri::XML '<ScrivenerProject />' }
  let(:project_node) { doc.root }

  describe 'parses the project' do
    before { project_node.add_child(Nokogiri::XML::Node.new('ProjectProperties', doc)) }

    describe 'title' do
      before {
        title_node = Nokogiri::XML::Node.new('ProjectTitle', doc)
        project_node.add_child(title_node)
        title_node.content = 'My Title'
      }

      it 'go' do
        scrivx.project.title.must_equal 'My Title'
      end

    end
  end
end
