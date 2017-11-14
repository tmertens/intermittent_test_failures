RSpec.describe "failures caused by differences between ruby and system times" do
  describe "differences between ruby and system timezones" do
    context "with UTC system time zone" do
      # This around block mimics a machine where the system time zone is UTC
      #
      # TIL: Interestingly, the "TZ" ENV key has special behavior and will not properly
      #      modify the system timezone when stubbed instead of being assigned.
      around do |example|
        original_system_timezone = ENV["TZ"]
        ENV["TZ"] = "UTC"
        begin
          example.run
        ensure
          ENV["TZ"] = original_system_timezone
        end
      end

      let(:local_time_zone) { ActiveSupport::TimeZone.new("America/Chicago") }

      before do
        # Set the Rails/ActiveSupport time zone to central time
        allow(Time).to receive(:zone).and_return(local_time_zone)
      end

      it "dates match during times of day when the local date and UTC (system) date match" do
        late_evening_utc_time = Time.utc(2011, 11, 10, 20)
        Timecop.freeze(late_evening_utc_time) do
          expect(Date.current).to eq(Date.today)
        end
      end

      it "dates do NOT match during times of day when local date does not match UTC (system) date" do
        early_morning_utc_time = Time.utc(2011, 11, 11, 2)
        Timecop.freeze(early_morning_utc_time) do
          expect(Date.current).to eq(Date.today)
        end
      end
    end
  end

  describe "mocked ruby date/time versus other processes" do
    it "unmocked ruby date/time matches external date/time (with same zone)" do
      local_date = `date "+%Y-%m-%d"`.chomp
      expect(Date.current.to_s).to eq local_date
    end

    it "mocked ruby date/time will not match other processes (with same zone)" do
      Timecop.freeze(2017, 1, 1) do
        local_date = `date "+%Y-%m-%d"`.chomp
        expect(Date.current.to_s).to eq local_date
      end
    end
  end
end