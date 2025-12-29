# coding: utf-8
#
# tested Buffalo AP
#    WSR3600BE4P Version 5.01
#


# interface info
# http://router_IP_address/cgi-bin/cgi?req=fnc&fnc=%24{include_html_utf8(%27../js/json/jp/packet_main.json%27,%20%24{RT_charset})}&_=1763559040121
#
#{
#"label_l2tp_server_packet_main":"L2TP/IPsecサーバー",
#"label_t2_packet_main":"インターフェース",
#"label_t3_packet_main":"送信パケット数",
#"label_t4_packet_main":"受信パケット数",
#"label_t5_packet_main":"正常&nbsp;&nbsp;",
#"label_t6_packet_main":"エラー",
#"label_t7_packet_main":"正常&nbsp;&nbsp;",
#"label_t8_packet_main":"エラー",
#"label_t9_packet_main":"Internet側有線",
#"label_label_wan1_packet_main":"Internet側有線",
#"label_label_wan2_packet_main":"INTERNETポート有線",
#"label_lan_ec_packet_main":"有線",
#"label_t10_packet_main":"LAN側有線",
#"label_wlan_total_ec_packet_main":"無線",
#"label_t11_packet_main":"LAN側無線",
#"label_t17_packet_main":"LAN側無線(6 GHz)",
#"label_t12_packet_main":"LAN側無線(5 GHz)",
#"label_t12_1_packet_main":"LAN側無線(5 GHz(W52/W53))",
#"label_t12_2_packet_main":"LAN側無線(5 GHz(W56))",
#"label_t13_packet_main":"LAN側無線(2.4 GHz)",
#"label_repeater_aorg_packet_main":"エアステーション間接続 子機",
#"label_repeater_11a_packet_main":"エアステーション間接続 子機(802.11be/ax/ac/n/a)",
#"label_repeater_11g_packet_main":"エアステーション間接続 子機(802.11be/ax/n/g/b)",
#"label_t16_packet_main":"6to4接続",
#"label_t14_packet_main":"現在設定がありません!"
#}

require 'date'

router_ip = ARGV[0]
interface = ARGV[1]

backup_file ="/tmp/buffalo-rateup-#{router_ip}.html"
html = ""
if (!File.exist?(backup_file) || (DateTime.now.to_time - File.mtime(backup_file)) > 120)
  require 'mechanize'
  agent = Mechanize.new
  agent.user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"

  start_url = "http://"+router_ip+"/cgi-bin/cgi?req=fnc&fnc=%24{include_html_utf8(%22packet_main.html%22,%20%24{RT_charset})}&rnd=58551333"
  #puts start_url
  #agent.get(start_url)
  fetch_str = "fetch -o #{backup_file} '#{start_url}'"
  system("#{fetch_str} > /dev/null 2>&1")
end

File.open(backup_file, "r:UTF-8") do |body|
  body.each_line do |oneline|
    html = html + oneline
  end
end

interfaces = { "Internet" =>    "label_label_wan2_packet_main",
               "Internet-ERROR" =>  "label_label_wan2_packet_main",
               "LAN" =>         "label_t10_packet_main",
               "LAN-ERROR" =>   "label_t10_packet_main",
               "Wi-Fi5GHz" =>   "label_t12_packet_main",
               "Wi-Fi5GHz-ERROR" =>   "label_t12_packet_main",
               "Wi-Fi2.4GHz" => "label_t13_packet_main",
               "Wi-Fi2.4GHz-ERROR" => "label_t13_packet_main"
             }

if (interfaces[interface] != nil)
  if_label = interfaces[interface]
  packet_info = html.scan(/<span data-file=packet_main class=#{if_label} ><\/span>\s*<\/th>\s*<td><div class="DIGIT">([0-9]*)<\/div><\/td>\s*<td><div class="DIGIT">([0-9]*)<\/div><\/td>\s*<td><div class="DIGIT">([0-9]*)<\/div><\/td>\s*<td><div class="DIGIT">([0-9]*)<\/div><\/td>\s*<\/tr>/)
#  puts if_label
#  pp packet_info
  send_packets = packet_info[0][0]
  send_packets_error = packet_info[0][1]
  recv_packets = packet_info[0][2]
  recv_packets_error = packet_info[0][3]
  if (interface =~ /ERROR/)
    puts  send_packets_error
    puts  recv_packets_error
  else
    puts  send_packets
    puts  recv_packets
  end
else
  puts 0
  puts 0
end
