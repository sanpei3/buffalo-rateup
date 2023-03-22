# buffalo-rateup

# Feature :
buffalo-rateup is mrtg module for Buffalo Wi-Fi Access Point Routers. It is used to monitor the traffic load on each band. However, not Bits per secound, Packets per second.

![image](https://user-images.githubusercontent.com/10361358/226916279-42b6dda3-df32-4205-b31a-6edf61d557b3.png)


# Usage :
Please refer sample configuration file(mrtg-sample.cfg) in the repository.

```
Target[Buffalo_IP_1]: `/usr/bin/ruby /etc/buffalo-rateup.rb [Buffalo_IP] [InterfaceName]`
```

Password for Ethernet Switch is in ~/.netrc.

```
machine 192.168.11.1
login UserName
password [Password for 192.168.11.1]
```

# Tested routers:

buffalo-rateup.rb
+ WHR-1166DHP3 Version 2.94
+ WHR-1166DHP3 Version 2.95
+ WSR-1166DHP3 Version 1.16
+ WSR-1166DHP3 Version 1.18
+ WSR-1166DHPL2 Version 1.08

buffalo-rateup-2.rb
+ WSR-2533DHPL  Version 1.08, 1.09
+ WEX-1800AX4  Version 1.13, 1.14
+ WEX-1800AX4EA  Version 1.13, 1.14
