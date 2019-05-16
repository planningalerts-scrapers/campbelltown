require '../epathway_scraper'
require 'date'

INIT_URL = "https://ebiz.campbelltown.nsw.gov.au/ePathway/Production/Web/GeneralEnquiry/ExternalRequestBroker.aspx?Module=EGELAP&Class=0PEAPP&Type=DATRAC"
INFO_URL = "https://ebiz.campbelltown.nsw.gov.au/ePathway/Production/Web/GeneralEnquiry/EnquiryLists.aspx?ModuleCode=LAP"

def scrape_result_row(result_row)
  fields = result_row.search('td').map { |f| f.inner_text }

  record = {
    'council_reference' => fields[0],
    'address' => fields[4],
    'description' => fields[1],
    'date_received' => Date.strptime(fields[2], '%d/%m/%Y').to_s,
    'date_scraped' => Date.today.to_s,
    'info_url' => INFO_URL
  }
  # on_notice_from and on_notice_to don't seem to be available for this council.
  # puts record
  puts "Saving record " + record["council_reference"] + " - " + record['address']
  ScraperWiki.save_sqlite(['council_reference'], record)
end

scraper = EpathwayScraper.new(base_url: INIT_URL)

agent = scraper.agent

current_page = agent.get(scraper.base_url)
current_page = scraper.click_search_on_form(current_page.form)
current_page_index = 1

loop do
  current_page.search('tr.ContentPanel, tr.AlternateContentPanel').each do |tr|
    scrape_result_row(tr)
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
