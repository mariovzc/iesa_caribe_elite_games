require "open-uri"
require "httparty"
require "nokogiri"
require "google_drive"

URL = "https://iesa-global.com/pro/torneos.php?torneo_id=586&sec=calendario&partidos=all&equipos=1104976&fecha=all&grupos=all"
TEAM_NAME = "CARIBE ELITE 2"

html = HTTParty.get(URL)

doc = Nokogiri::HTML(html)

games_table = doc.css("table")
## setup drive
def worksheet
  ## you need to generate client_secret
  @session ||= GoogleDrive::Session.from_service_account_key("client_secret.json")
  @spreadsheet ||= @session.spreadsheet_by_title("partidos_ce")
  @worksheet ||= @spreadsheet.worksheets.first
end

# App Header
theader = games_table.css("thead").css("tr").css("th")
column_names = theader.map do | th |
  th.text.downcase.tr(' ', '_')
end

games = []
tbody = games_table.css("tbody").css("tr")
tbody.each do |tr|
  tr_items = tr.css("td").map do |td|
    td.text.strip()
  end
  games.push(tr_items) if (tr_items[3].strip() == TEAM_NAME || tr_items[5].strip() == TEAM_NAME)
end

worksheet.delete_rows(2, worksheet.num_rows)
games.each do |game|
  worksheet.insert_rows(worksheet.num_rows + 1, [game])
end

worksheet.insert_rows(worksheet.num_rows + 2, [["Ultima actualizacion", Time.now.strftime("%d/%m/%Y %I:%M %p")]])

worksheet.save
