require 'rivener/scrivx'

require File.expand_path('../../spec_helper', __FILE__)

require 'nokogiri'

describe Rivener::Scrivx do
  let(:scrivx) { Rivener::Scrivx.new(scrivx: scrivx_doc, path: scrivener_path) }
  let(:scrivener_path) { Pathname 'my.scriv'}
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

  describe 'parses the Binder' do
    describe 'BinderItem elements' do
      # Every project has Draft, Research, and Trash folders
      it 'as binder_items' do
        project.binder.children.size.must_equal 3
      end

      it 'with an id' do
        items = project.binder.children
        items.map(&:id).sort.must_equal ['0', '1', '2']
      end

      it 'with a title' do
        items = project.binder.children
        items.find{ |item| item.id == '0' }.title.must_equal 'Draft'
        items.find{ |item| item.id == '1' }.title.must_equal 'Research'
        items.find{ |item| item.id == '2' }.title.must_equal 'Trash'
      end

      it 'with a type' do
        items = project.binder.children
        items.find{ |item| item.id == '0' }.type.must_equal 'DraftFolder'
        items.find{ |item| item.id == '1' }.type.must_equal 'ResearchFolder'
        items.find{ |item| item.id == '2' }.type.must_equal 'TrashFolder'
      end

      it 'with an include_in_compile property' do
        # These all have IncludeInCompile=Yes.
        # Omitted IncludeInCompile means No.
        scrivx_doc.at_xpath(%{.//BinderItem[@ID='2']/MetaData/IncludeInCompile}).remove
        items = project.binder.children
        items.find{ |item| item.id == '0' }.include_in_compile?.must_equal true
        items.find{ |item| item.id == '1' }.include_in_compile?.must_equal true
        items.find{ |item| item.id == '2' }.include_in_compile?.must_equal false
      end

      it 'with the binder as its parent' do
        project.binder.children.each{ |item| item.parent.must_be_same_as project.binder }
      end
    end

    describe 'children of BinderItems' do
      let(:draft) { project.binder.children.find{ |item| item.id == '0' } }
      let(:research) { project.binder.children.find{ |item| item.id == '1' } }
      before do
        draft_folder_children_node = Nokogiri::XML::DocumentFragment.parse <<-SCRIVX
          <Children>
            <BinderItem ID='11' Type='Folder'>
              <Title>Chapter One</Title>
              <MetaData />
              <Children>
                <BinderItem ID='21' Type='Text'>
                  <Title>Scene One</Title>
                  <MetaData>
                    <IncludeInCompile>Yes</IncludeInCompile>
                  </MetaData>
                </BinderItem>
              </Children>
            </BinderItem>
          </Children>
        SCRIVX
        draft_folder_node = scrivx_doc.at_xpath(%{.//BinderItem[@ID='0']})
        draft_folder_node.add_child draft_folder_children_node
      end

      it %{lists each child in its parent's binder_items} do
        draft_child = draft.children.first
        draft_child.id.must_equal '11'
        draft_grandchild = draft_child.children.first
        draft_grandchild.id.must_equal '21'
      end

      it %{lists each binder item as its children's parent} do
        chapter_one = draft.children.first
        chapter_one.parent.must_be_same_as draft
        scene_one = chapter_one.children.first
        scene_one.parent.must_be_same_as chapter_one
      end

      it 'each child has all of the binder item properties' do
        chapter_one = draft.children.first
        chapter_one.title.must_equal 'Chapter One'
        chapter_one.id.must_equal '11'
        chapter_one.type.must_equal 'Folder'
        chapter_one.include_in_compile?.must_equal false
        scene_one = chapter_one.children.first
        scene_one.title.must_equal 'Scene One'
        scene_one.id.must_equal '21'
        scene_one.type.must_equal 'Text'
        scene_one.include_in_compile?.must_equal true
      end

      it 'yields empty binder_item list if no children' do
        research.children.must_equal []
        chapter_one = draft.children.first
        scene_one = chapter_one.children.first
        scene_one.children.must_equal []
      end
    end
  end

  # Note that these methods DO NOT determine whether the file exists.
  describe 'calculates the path' do
    let(:draft) { project.binder.children.find{ |item| item.id == '0' } }
    let(:research) { project.binder.children.find{ |item| item.id == '1' } }
    let(:trash) { project.binder.children.find{ |item| item.id == '2' } }

    it 'to the file' do
      draft.file_path.must_equal scrivener_path / 'Files/Docs/0.rtf'
      research.file_path.must_equal scrivener_path / 'Files/Docs/1.rtf'
      trash.file_path.must_equal scrivener_path / 'Files/Docs/2.rtf'
    end

    it 'to the notes' do
      draft.notes_path.must_equal scrivener_path / 'Files/Docs/0_notes.rtf'
      research.notes_path.must_equal scrivener_path / 'Files/Docs/1_notes.rtf'
      trash.notes_path.must_equal scrivener_path / 'Files/Docs/2_notes.rtf'
    end

    it 'to the synopsis' do
      draft.synopsis_path.must_equal scrivener_path / 'Files/Docs/0_synopsis.txt'
      research.synopsis_path.must_equal scrivener_path / 'Files/Docs/1_synopsis.txt'
      trash.synopsis_path.must_equal scrivener_path / 'Files/Docs/2_synopsis.txt'
    end
  end
end
