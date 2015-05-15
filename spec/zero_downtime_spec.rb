require 'spec_helper'

RSpec.describe ZeroDowntime do
  it 'has a version number' do
    expect(ZeroDowntime::VERSION).not_to be nil
  end
end
