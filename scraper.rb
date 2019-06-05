require 'epathway_scraper'

EpathwayScraper.scrape_and_save(
  "https://ebiz.campbelltown.nsw.gov.au/ePathway/Production",
  list_type: :all, state: "NSW"
)
