RSpec.describe "failures due to data pollution" do
  let(:fake_cache) do
    Class.new do
      def self.cache
        @cache ||= []
      end

      def self.where(*_args)
        cache
      end

      def self.insert(something)
        cache << something
      end
    end
  end

  it "passes when the cache is empty" do
    my_record = double("Some Record Instance")
    fake_cache.insert(my_record)

    collection = fake_cache.where(foo: :bar)

    expect(collection.count).to eq 1
    expect(collection).to eq [my_record]
  end

  it "fails when the cache is not empty" do
    # FIXME: Make this test always pass, WITHOUT clearing the cache!

    # The loop simulates multiple tests running that dirty the cache:
    10.times do
      my_record = double("Some Record Instance")
      fake_cache.insert(my_record)

      collection = fake_cache.where(foo: :bar)

      expect(collection.count).to eq 1
      expect(collection).to eq [my_record]
    end
  end
end
