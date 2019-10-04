# To avoid getting error during test execution.
if Rails.env.test?
    CarrierWave.configure do |config|
        config.enable_processing = false
    end
end