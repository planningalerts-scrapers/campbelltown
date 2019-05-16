require '../epathway_scraper'
require 'date'

INIT_URL = "https://ebiz.campbelltown.nsw.gov.au/ePathway/Production/Web/GeneralEnquiry/ExternalRequestBroker.aspx?Module=EGELAP&Class=0PEAPP&Type=DATRAC"
INFO_URL = "https://ebiz.campbelltown.nsw.gov.au/ePathway/Production/Web/GeneralEnquiry/EnquiryLists.aspx?ModuleCode=LAP"

scraper = EpathwayScraper.new(base_url: INIT_URL)

agent = scraper.agent

current_page = agent.get(scraper.base_url)
current_page = scraper.click_search_on_form(current_page.form)
current_page_index = 1

loop do
  table = current_page.at("table.ContentPanel")
  scraper.extract_table_data(table).each do |row|
    record = {
      'council_reference' => row["Application Number"],
      'address' => row["Location Address"],
      'description' => row["Description"],
      'date_received' => Date.strptime(row["Date Lodged"], '%d/%m/%Y').to_s,
      'date_scraped' => Date.today.to_s,
      'info_url' => INFO_URL
    }
    # on_notice_from and on_notice_to don't seem to be available for this council.
    # puts record
    puts "Saving record " + record["council_reference"] + " - " + record['address']
    ScraperWiki.save_sqlite(['council_reference'], record)
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
