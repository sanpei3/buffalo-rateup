# coding: utf-8

require 'pp'
require 'mechanize'

interface = ARGV[0]

router_ip = "192.168.11.1"
password = ARGV[1]

backup_file ="/tmp/buffalo-rateup.html"
html = ""
if (File.exist?(backup_file) && (DateTime.now.to_time - File.mtime(backup_file)) <= 15)
  File.open(backup_file, "r:UTF-8") do |body|
    body.each_line do |oneline|
      html = html + oneline.force_encoding("SJIS").encode("UTF-8")
    end
  end
else
  agent = Mechanize.new #{|a| a.log = Logger.new(STDERR) }
  agent.get("http://"+router_ip+"/login.html")
  #puts agent.page.body
  sleep(0.05)
  
  agent.page.form_with(:id => "authform") do |form|
    form.field_with(:name => "nosave_Username").value = "admin"
    form.field_with(:name => "nosave_Password").value=password
    form.click_button #submitをクリック
  end
  sleep(0.05)
  agent.get("http://"+router_ip+"/packet.html")
  #puts agent.page.body
  File.write(backup_file, agent.page.body)
  html = agent.page.body.force_encoding("SJIS").encode("UTF-8")
  agent.get("http://"+router_ip+"/logout.html")
end

interfaces = { "Internet" =>    "Internet.*",
               "LAN" =>         "LAN側有線.*",
               "Wi-Fi5GHz" =>   "LAN側無線.*5GHz.*",
               "Wi-Fi2.4GHz" => "LAN側無線.*2.4GHz.*"}

if (html =~ /<th>#{interfaces[interface]}<\/th>\n\s*<td><div class="DIGIT"><!--\d*-->(\d*)<\/div><\/td>\n\s*<td><div class="DIGIT"><!--\d*-->(\d*)<\/div><\/td>\n\s*<td><div class="DIGIT"><!--\d*-->(\d*)<\/div><\/td>\n\s*<td><div class="DIGIT"><!--\d*-->(\d*)<\/div><\/td>/)
  puts $1
#  puts $2
  puts $3
#  puts $4
end

