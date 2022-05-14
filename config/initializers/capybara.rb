require "selenium/webdriver"

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'goog:chromeOptions': {
      args: %w[headless enable-features=NetworkService,NetworkServiceInProcess]
    }
  )

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    capabilities: capabilities
end

Capybara.default_driver = :headless_chrome
Capybara.javascript_driver = :headless_chrome