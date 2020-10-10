# frozen_string_literal: true

require_relative '../lib/kinchan'
require_relative 'tasks/google'

RSpec.describe Kinchan do
  it 'defines the default browser' do
    expect(Kinchan.browser).to eq(:chrome)
  end

  it 'allows the browser to be redefined' do
    Kinchan.browser = :firefox
    expect(Kinchan.browser).to eq(:firefox)
  end

  it "doesn't specify default browser options" do
    expect(Kinchan.browser_options).to eq(nil)
  end

  it 'allows the browser options to be defined' do
    Kinchan.browser_options = :dummy_options
    expect(Kinchan.browser_options).to eq(:dummy_options)
  end

  it 'can restore the default browser settings' do
    Kinchan.restore_defaults
    expect(Kinchan.browser).to eq(:chrome)
    expect(Kinchan.browser_options).to eq(nil)
  end

  it 'can run the test tasks' do
    Google::HighLevel::SearchForTerm.new(query: 'kinchan').run
  end
end

RSpec.describe Kinchan::Task do
  it 'can find defined tasks' do
    class NuTask < Kinchan::Task; end
    expect(Kinchan::Task.find_task(:nutask)).to eq(NuTask)
  end
end
