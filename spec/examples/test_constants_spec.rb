RSpec.describe "failures due to declaration of constants in test" do
  # FIXME: One of these tests fails.  But why??? Fix them using standard rspec syntax.

  context "when the EXPECTED_VALUE is true" do
    EXPECTED_VALUE = true

    it "is true" do
      expect(true).to eq UNSCOPED
    end
  end

  context "when the EXPECTED_VALUE is false" do
    EXPECTED_VALUE = false

    it "is false" do
      expect(false).to eq UNSCOPED
    end
  end
end
