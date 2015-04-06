require 'rivener/scrivx'

require File.expand_path('../../spec_helper', __FILE__)

require 'nokogiri'

describe Rivener::Scrivx do
  let(:scrivx) { Rivener::Scrivx.new(scrivx_doc) }
  let(:scrivx_doc) { basic_scrivx_document }
  let(:scrivx_project_node) { scrivx_doc.at_css 'ScrivenerProject' }
  let(:scrivx_project_properties_node) { scrivx_project_node.at_css 'ProjectProperties' }
  let(:project) { scrivx.project }

  describe 'parses the ProjectProperties' do
    describe 'ProjectTitle' do
      before {
        scrivx_project_properties_node.at_css('ProjectTitle').content = 'My Fantastic Title'
      }

      it 'as the project title' do
        project.title.must_equal 'My Fantastic Title'
      end
    end

    describe 'AbbreviatedTitle' do
      before {
        scrivx_project_properties_node.at_css('AbbreviatedTitle').content = 'Fantastic'
      }

      it 'as the project abbreviated title' do
        project.abbreviated_title.must_equal 'Fantastic'
      end
    end

    describe 'FullName' do
      before {
        scrivx_project_properties_node.at_css('FullName').content = 'Author Full Name'
      }

      it 'as the project author full name' do
        project.author_full_name.must_equal 'Author Full Name'
      end
    end

    describe 'FirstName' do
      before {
        scrivx_project_properties_node.at_css('FirstName').content = 'Author First Name'
      }

      it 'as the project author first name' do
        project.author_first_name.must_equal 'Author First Name'
      end
    end

    describe 'LastName' do
      before {
        scrivx_project_properties_node.at_css('LastName').content = 'Author Last Name'
      }

      it 'as the project author last name' do
        project.author_last_name.must_equal 'Author Last Name'
      end
    end
  end
end
