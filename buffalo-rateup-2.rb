# coding: utf-8
#
# tested Buffalo AP
#    WSR-2533DHPL  Version 1.08, 1.09
#    WEX-1800AX4  Version 1.13, 1.14
#    WEX-1800AX4EA  Version 1.13, 1.14

#require 'pp'
require 'date'

router_ip = ARGV[0]
interface = ARGV[1]

backup_file ="/tmp/buffalo-rateup-#{router_ip}.html"

html = ""
if (File.exist?(backup_file) && (DateTime.now.to_time - File.mtime(backup_file)) <= 120)
  File.open(backup_file, "r:UTF-8") do |body|
    body.each_line do |oneline|
      html = html + oneline
    end
  end
else
  require 'netrc'
  n = Netrc.read
  user, password = n[router_ip]
  require 'digest/md5'
  md5password =  Digest::MD5.hexdigest(password)
  require 'mechanize'
  agent = Mechanize.new
#  agent.redirect_ok = true
#  agent.follow_meta_refresh = true
  agent.user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
  
  agent.get("http://"+router_ip+"/login.html")
  sleep(0.05)
  referer = "http://"+router_ip+"/login.html"

  data_image = agent.page.body.scan(/^<img title=spacer src=\"(data:image\/gif;base64,[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+\/=]+)/)[0][0]
  #
  # /tmp/global.js is from http://[router_ip]/js/global.js
  # and only ArcBase function
  # add below code at bottom of globa.js
  # x = process.argv[2]
  # hash = ArcBase.decode(x.substring(78));
  # console.log(hash);
  #
  token = `/usr/local/bin/node /tmp/global.js "#{data_image}"`
  token = token.chomp

  currentTime = (Time.now.to_i) *1000 + (rand*1000).floor
  nextTime = currentTime + 2
  
  agent.get("http://"+router_ip+"/cgi/cgi_login.js?_tn=#{token}&_t=#{currentTime}&_=#{nextTime}", nil, referer)
  sleep(0.05)

#  currentTime = (Time.now.to_i) *1000 + (rand*1000).floor
#  nextTime = currentTime + 2
#  agent.get("http://"+router_ip+"/cgi/cgi_busy_status.js?_tn=#{token}&_t=#{currentTime}&_=#{nextTime}", nil, referer)
#  sleep(0.05)
#
#  currentTime = (Time.now.to_i) *1000 + (rand*1000).floor
#  nextTime = currentTime + 2
#  agent.get("http://"+router_ip+"/cgi/cgi_deviceinfo_basic.js?_tn=#{token}&_t=#{currentTime}&_=#{nextTime}", nil, referer)
#  sleep(0.05)

  options =           {"name" => "admin",
              "pws" => md5password,
              "url" => "/",
              "mobile" => "0",
              "httoken" => token
                      }
  headers = {"referer" => referer}
  page = agent.post("http://"+router_ip+"/login.cgi",options, headers)
  sleep(0.05)
  agent.get("http://"+router_ip+"/")
  sleep(0.05)

  random = rand * 100000000.floor
  agent.get("http://"+router_ip+"/packet.html?rnd=#{random}")
  data_image = agent.page.body.scan(/^<img title=spacer src=\"(data:image\/gif;base64,[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+\/=]+)/)[0][0]
  token = `/usr/local/bin/node /tmp/global.js "#{data_image}"`
  token = token.chomp
  sleep(0.05)

  referer = "http://"+router_ip+"/packet.html?rnd=#{random}"

  currentTime = (Time.now.to_i) *1000 + (rand*1000).floor
  nextTime = currentTime + 2
  agent.get("http://"+router_ip+"/cgi/cgi_packet.js?_tn=#{token}&_t=#{currentTime}&_=#{nextTime}", nil, referer)

  html = agent.page.body
  File.write(backup_file, html)
  referer = "http://"+router_ip+"/"
  agent.get("http://"+router_ip+"/logout.html", nil, referer)
  data_image = agent.page.body.scan(/^<img title=spacer src=\"(data:image\/gif;base64,[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+\/=]+)/)[0][0]
  token = `/usr/local/bin/node /tmp/global.js "#{data_image}"`
  token = token.chomp
  sleep(0.05)

  options =           {
              "httoken" => token
                      }
  headers = {"referer" => "http://"+router_ip+"/logout.html",
             "Origin" => "http://"+router_ip,
             "Upgrade-Insecure-Requests" => "1"}
  page = agent.post("http://"+router_ip+"/logout.cgi", options, headers)
end

interfaces = { "Internet" =>    nil,
               "Internet-ERROR" =>   nil,
               "LAN" =>         0,
               "LAN-ERROR" =>   1,
               "Wi-Fi5GHz" =>   8,
               "Wi-Fi5GHz-ERROR" =>   9,
               "Wi-Fi2.4GHz" => 12,
               "Wi-Fi2.4GHz-ERROR" => 13
             }

if (interface =~ /^[0-9]+/)
  packet_info = html.scan(/^var packet_info = \[\[ ([0-9]*), ([0-9]*), ([0-9]*), ([0-9]*)\],\[ ([0-9]*), ([0-9]*), ([0-9]*), ([0-9]*)\],\[ ([0-9]*), ([0-9]*), ([0-9]*), ([0-9]*)\],\[ ([0-9]*), ([0-9]*), ([0-9]*), ([0-9]*)\],\[ ([0-9]*), ([0-9]*), ([0-9]*), ([0-9]*)\],\[ ([0-9]*), ([0-9]*), ([0-9]*), ([0-9]*)\],\[ ([0-9]*), ([0-9]*), ([0-9]*), ([0-9]*)\]/)
  puts  packet_info[0][interface.to_i + 2]
  puts  packet_info[0][interface.to_i + 0]
elsif (interfaces[interface] != nil)
  packet_info = html.scan(/^var packet_info = \[\[ ([0-9]*), ([0-9]*), ([0-9]*), ([0-9]*)\],\[ ([0-9]*), ([0-9]*), ([0-9]*), ([0-9]*)\],\[ ([0-9]*), ([0-9]*), ([0-9]*), ([0-9]*)\],\[ ([0-9]*), ([0-9]*), ([0-9]*), ([0-9]*)\]/)
  puts  packet_info[0][interfaces[interface] + 2]
  puts  packet_info[0][interfaces[interface]]
else
  puts 0
  puts 0
end
