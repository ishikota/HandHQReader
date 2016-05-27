require 'spec_helper'

describe FileReader do
  let(:f_name) { "spec/data/file_example.txt" }

  it "should read file and separate by round" do
    data = FileReader.read(f_name)
    expect(data.size).to eq 3
  end

end
