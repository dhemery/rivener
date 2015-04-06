module Rivener
  class Project
    attr_reader :title
    
    def initialize(title:)
      @title = title
    end
  end
end
