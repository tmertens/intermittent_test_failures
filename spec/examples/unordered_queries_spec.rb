RSpec.describe "failures due to unordered queries" do
  let(:result_set) { [1, 2, 3] }
  let(:model_class) do
    # Mock model class demonstrating how postgres behaves
    # when ordering of a query is not specified
    Class.new do
      def initialize(collection)
        @collection = collection
      end

      def self.where(*_args)
        unordered_results = RESULT_SET.shuffle
        new(unordered_results)
      end

      def order_by(*_args)
        @collection.sort
      end
    end
  end

  before do
    stub_const("RESULT_SET", result_set)
  end

  it "will fail sometimes if it expects results to be returned in the order they are created" do
    # TODO: Make this test always pass, without calling `order_by`
    10.times do
      collection = model_class.where(foo: :bar)
      expect(collection).to eq [1, 2, 3]
    end
  end

  it "will pass when the result set is explicitly ordered" do
    10.times do
      collection = model_class.where(foo: :bar).order_by(foo: :asc)
      expect(collection).to eq [1, 2, 3]
    end
  end
end