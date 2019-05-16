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

    next_link = current_page.links_with(:text => (current_page_index+1).to_s)[0]
    break if !next_link
    params = /javascript:WebForm_DoPostBackWithOptions\(new WebForm_PostBackOptions\("([^"]*)", "", false, "", "([^"]*)", false, true\)\)/.match(next_link.href)

    aspnetForm = current_page.forms_with(:name => "aspnetForm")[0]
    aspnetForm.action = params[2]
    aspnetForm['__EVENTTARGET'] = params[1]
    aspnetForm['__EVENTARGUMENT'] = ""

    current_page = agent.submit(aspnetForm)
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
