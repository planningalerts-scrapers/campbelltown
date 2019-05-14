# A simple regression test
# Simulates a fixed external website using data from fixtures
# Checks that the data is as expected

require 'vcr'
require 'scraperwiki'
require 'yaml'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end

File.delete("./data.sqlite") if File.exist?("./data.sqlite")

VCR.use_cassette("scraper") do
  require "./scraper"
end

expected = YAML.load(File.read("fixtures/expected.yml"))
results = ScraperWiki.select("* from data")

unless results == expected
  File.open("fixtures/actual.yml", "w") do |f|
    f.write(results.to_yaml)
  end
  raise "Failed"
end
puts "Succeeded"
