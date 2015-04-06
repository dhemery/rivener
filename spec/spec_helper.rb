require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use!

def basic_scrivx_document
  Nokogiri::XML::DocumentFragment.parse <<-SCRIVX
<ScrivenerProject>
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
