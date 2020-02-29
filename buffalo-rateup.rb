# coding: utf-8
#
# tested Buffalo AP
#    WHR-1166DHP3 Version 2.94
#    WSR-1166DHP3 Version 1.16


require 'pp'
require 'mechanize'

router_ip = ARGV[0]
interface = ARGV[1]
password = ARGV[2]

backup_file ="/tmp/buffalo-rateup-#{router_ip}.html"
backup_dir = "/tmp/BUFFALO-RATEUP-#{router_ip}/"

html = ""
if (File.exist?(backup_file) && (DateTime.now.to_time - File.mtime(backup_file)) <= 15)
  File.open(backup_file, "r:UTF-8") do |body|
    body.each_line do |oneline|
      html = html + oneline.force_encoding("SJIS").encode("UTF-8")
    end
  end
else
  agent = Mechanize.new
  agent.get("http://"+router_ip+"/login.html")
  sleep(0.05)
  
  agent.page.form_with(:id => "authform") do |form|
    form.field_with(:name => "nosave_Username").value = "admin"
    form.field_with(:name => "nosave_Password").value=password
    form.click_button #submitをクリック
  end
  sleep(0.05)
  agent.get("http://"+router_ip+"/packet.html")
  File.write(backup_file, agent.page.body)
  File.write(backup_dir + Time.now.strftime("%y%m%d-%H%M") + ".html", agent.page.body)
  html = agent.page.body.force_encoding("SJIS").encode("UTF-8")
  agent.get("http://"+router_ip+"/logout.html")
end

interfaces = { "Internet" =>    "Internet.*",
               "Internet-ERROR" =>    "Internet.*",
               "LAN" =>         "LAN側有線.*",
               "LAN-ERROR" =>         "LAN側有線.*",
               "Wi-Fi5GHz" =>   "LAN側無線.*5GHz.*",
               "Wi-Fi5GHz-ERROR" =>   "LAN側無線.*5GHz.*",
               "Wi-Fi2.4GHz" => "LAN側無線.*2.4GHz.*",
               "Wi-Fi2.4GHz-ERROR" => "LAN側無線.*2.4GHz.*"}

if (html =~ /<th>#{interfaces[interface]}<\/th>\n\s*<td><div class="DIGIT"><!--\d*-->(\d*)<\/div><\/td>\n\s*<td><div class="DIGIT"><!--\d*-->(\d*)<\/div><\/td>\n\s*<td><div class="DIGIT"><!--\d*-->(\d*)<\/div><\/td>\n\s*<td><div class="DIGIT"><!--\d*-->(\d*)<\/div><\/td>/)
  send = $1
  send_error = $2
  recv = $3
  recv_error = $4
  if (interface =~ /ERROR$/)
    puts send_error
    puts recv_error
  else
    puts send
    puts recv
  end
end
