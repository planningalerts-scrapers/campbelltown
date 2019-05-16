require '../epathway_scraper'

scraper = EpathwayScraper.new(
  base_url: "https://ebiz.campbelltown.nsw.gov.au/ePathway/Production/Web/GeneralEnquiry/EnquiryLists.aspx?ModuleCode=LAP",
  index: 2
)

scraper.scrape_and_save
