#!/usr/bin/env ruby

dc = Process.spawn("docker-compose up")

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'selenium-webdriver', "~> 4.0.0.beta2"
end

caps = Selenium::WebDriver::Remote::Capabilities.firefox(
  proxy: Selenium::WebDriver::Proxy.new(
    http: "127.0.0.1:18080",
    ssl: "127.0.0.1:18080"
  )
)
caps['acceptInsecureCerts'] = true

profile = Selenium::WebDriver::Firefox::Profile.new
profile["security.cert_pinning.enforcement_level"] = 0
profile["security.enterprise_roots.enabled"] = true

opts = Selenium::WebDriver::Firefox::Options.new(
  args: %w(--devtools --new-instance),
  profile: profile
)

driver = Selenium::WebDriver.for(:firefox, capabilities: caps, options: opts)

at_exit do
  begin
    driver.quit
  rescue Selenium::WebDriver::Error::UnknownError => e
    if e.message =~ /Failed to decode response from marionette/
      # browser probably already closed, so ignore
    else
      raise
    end
  ensure
    Process.kill("INT", dc)
    Process.kill("INT", dc) # hard kill, as we don't care about cleaning up nicely here
    Process.wait
  end
end

plex = driver.window_handle
mitm = driver.manage.new_window(:tab)

until driver.window_handles.length >= 2 do
  sleep 0.2
end

begin
  driver.switch_to.window(mitm)
  driver.get("http://localhost:8081")
  driver.switch_to.window(plex)
  driver.get("http://localhost:32400/web")
rescue Selenium::WebDriver::Error::UnknownError => e
  if e.message =~ /Reached error page: about:neterror\?e=connectionFailure/
    sleep 1
    retry
  end
else
  loop do
    sleep 10
  rescue Interrupt
    # ignore
  end
end

