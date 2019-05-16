require '../epathway_scraper'
require 'date'

def scrape(scraper, agent)
  current_page = scraper.pick_type_of_search
  current_page = scraper.click_search_on_form(current_page.form)
  current_page_index = 1

  loop do
    scraper.scrape_index_page(current_page) do |record|
      yield record
    end

    current_page = scraper.click_next_page_link(current_page, current_page_index)
    break if current_page.nil?
    current_page_index += 1
  end
end

scraper = EpathwayScraper.new(
  base_url: "https://ebiz.campbelltown.nsw.gov.au/ePathway/Production/Web/GeneralEnquiry/EnquiryLists.aspx?ModuleCode=LAP",
  index: 2
)

agent = scraper.agent

scrape(scraper, agent) do |record|
  puts "Saving record " + record["council_reference"] + " - " + record['address']
  ScraperWiki.save_sqlite(['council_reference'], record)
end
