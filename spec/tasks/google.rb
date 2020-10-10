require_relative '../../lib/kinchan'

module Google
  class VisitHomePage < Kinchan::Task
    def execute(browser)
      browser.navigate.to 'https://www.google.com'
    end
  end

  class ExecuteSearch < Kinchan::Task
    def initialize(**options)
      super

      @query = options[:query]
    end

    def execute(browser)
      browser.find_element(:name, 'q')&.send_keys(@query) # input the query
      browser.find_element(:id, 'tsf')&.submit # submit the search form
    end
  end

  module HighLevel
    class SearchForTerm < Kinchan::Task
      def initialize(**options)
        super

        @before_tasks << { task: :VisitHomePage }
        @after_tasks << { task: :ExecuteSearch, options: options }
      end
    end
  end
end
