require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use!

def basic_scrivx_document
  Nokogiri::XML::DocumentFragment.parse <<-SCRIVX
<ScrivenerProject>
  <Binder>
    <BinderItem ID='0' Type='DraftFolder'>
      <Title>Draft</Title>
      <MetaData>
        <IncludeInCompile>Yes</IncludeInCompile>
      </MetaData>
    </BinderItem>
    <BinderItem ID='1' Type='ResearchFolder'>
      <Title>Research</Title>
      <MetaData>
        <IncludeInCompile>Yes</IncludeInCompile>
      </MetaData>
    </BinderItem>
    <BinderItem ID='2' Type='TrashFolder'>
      <Title>Trash</Title>
      <MetaData>
        <IncludeInCompile>Yes</IncludeInCompile>
      </MetaData>
    </BinderItem>
  </Binder>
  <ProjectProperties>
    <AbbreviatedTitle />
    <FirstName />
    <FullName />
    <LastName />
    <ProjectTitle />
  </ProjectProperties>
</ScrivenerProject>
SCRIVX
end
