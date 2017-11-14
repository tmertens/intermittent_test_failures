require "forwardable"

RSpec.describe "failures due to singleton cache mutation" do
  # TIL: Using the name "singleton_class" here breaks rspec:
  let(:test_singleton_class) do
    Class.new do
      class << self
        extend Forwardable

        def instance
          @instance ||= self.new
        end

        def_delegators :instance, :configure, :configuration
      end

      def configure
        yield self
      end

      def configuration
        @configuration ||= defaults
      end

      def enable_feature
        configuration[:feature_enabled] = true
      end

      def some_option=(new_value)
        configuration[:some_option] = new_value
      end

      private

      def defaults
        { feature_enabled: false,
          some_option:     "Caching is hard" }
      end
    end
  end

  it "passes when the singleton has not been mutated" do
    test_singleton_class.configure do |c|
      c.enable_feature
    end

    expect(test_singleton_class.configuration).to eq(
      { feature_enabled: true,
        some_option:     "Caching is hard" }
    )
  end

  context "the singleton has been mutated by a previous test" do
    before do
      # Simulate a previous test mutating a global singleton:
      test_singleton_class.configure do |c|
        c.some_option = "I love test mutations"
      end
    end

    it "can fail if the singleton's initial state is not what the test expects" do
      # FIXME: Make this test always pass, WITHOUT resetting the singleton.
      #        The test also must not permanently mutate the state of the singleton.
      test_singleton_class.configure do |c|
        c.enable_feature
      end

      expect(test_singleton_class.configuration).to eq(
        { feature_enabled: true,
          some_option:     "Caching is hard" }
      )
    end
  end
end
