RSpec.describe "failures caused by frozen time" do
  let(:model) { Struct.new(:name, :created_at) }
  let(:relation_class) do
    # Mock ActiveRecord::Relation or other collection class
    Class.new do
      def initialize(collection)
        @collection = collection
      end

      def where(*_args)
        unordered_results = @collection.shuffle
        self.class.new(unordered_results)
      end

      def chronologic
        @collection.sort_by(&:created_at)
      end
    end
  end

  describe "#chronologic" do
    it "returns records in order by created at" do
      # FIXME: This test fails. Fix it before time runs out!
      # The loop here ensures an intermittent failure occurs every time the test is run.
      10.times do
        Timecop.freeze(Time.new(2017, 1, 1, 6, 0, 0)) do
          instances = %w{foo bar baz}.map { |name| model.new(name, Time.current) }
          relation  = relation_class.new(instances)

          ordered_result = relation.where(foo: :bar).chronologic
          expect(ordered_result).to eq instances
        end
      end
    end
  end
end
