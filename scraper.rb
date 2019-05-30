require 'epathway_scraper'

EpathwayScraper::Scraper.scrape_and_save(
  "https://ebiz.campbelltown.nsw.gov.au/ePathway/Production",
  list_type: :all
)
