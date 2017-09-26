Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Test framework
    with.test_framework :rspec

    # Libraries
    with.library :rails
  end
end
