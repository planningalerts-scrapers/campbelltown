require 'scraperwiki'
require 'mechanize'
require 'date'

INIT_URL = "https://ebiz.campbelltown.nsw.gov.au/ePathway/Production/Web/GeneralEnquiry/ExternalRequestBroker.aspx?Module=EGELAP&Class=0PEAPP&Type=DATRAC"
INFO_URL = "https://ebiz.campbelltown.nsw.gov.au/ePathway/Production/Web/GeneralEnquiry/EnquiryLists.aspx?ModuleCode=LAP"

def titleize(s)
  s.gsub(/\w+/) { |w| w.capitalize }
end

def scrape_result_page(result_page)
  result_page.search('tr.ContentPanel').each { |tr| scrape_result_row(tr) }
  result_page.search('tr.AlternateContentPanel').each { |tr| scrape_result_row(tr) }
end

def scrape_result_row(result_row)
  fields = result_row.search('td')

  council_reference = fields[0].search('a')[0].inner_text

  record = { 'council_reference' => council_reference }
  record['address'] = fields[4].search('span')[0].inner_text
  record['description'] = fields[1].inner_text
  record['date_received'] = Date.strptime(fields[2].search('span')[0].inner_text, '%d/%m/%Y').to_s
  record['date_scraped'] = Date.today.to_s
  record['info_url'] = INFO_URL
  record['comment_url'] = 'mailto:council@campbelltown.nsw.gov.au'
  # on_notice_from and on_notice_to don't seem to be available for this council.
  # puts record
  puts "Saving record " + council_reference + " - " + record['address']
  ScraperWiki.save_sqlite(['council_reference'], record)
end

agent = Mechanize.new
agent.verify_mode = OpenSSL::SSL::VERIFY_NONE

current_page = agent.get(INIT_URL)
current_page = current_page.form.submit(current_page.form.button_with(:value=>'Search'))
current_page_index = 1

loop do
  scrape_result_page(current_page)

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
