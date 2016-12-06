#!/usr/bin/ruby
=begin
networkhex.rb
Sanjiv Kawa (@skawasec)
www.popped.io
December 5, 2016

This script takes an ip address and/or port and converts it to hex
=end

require 'ipaddr'

ip = "192.168.156.156"
port = "3879"

# take a ip, split on . and convert it to hex
def hexFormatIp(ip)
   ipArr = Array.new

   for i in 0 .. 3
    current = ip.split(".")[i]
    ipArr.push "\\x#{current.to_i.to_s(16).rjust(2, '0').scan(/.{1,2}/).join}"
  end

  return  ipArr.join
end

# take a port, split every 2 characters . and convert it to hex
def hexFormatPort(port)

  port = port.to_i.to_s(16).rjust(4, '0').scan(/.{1,2}/)
 
  hexFormatted = Array.new

  for element in port
     hexFormatted.push "\\x#{element}" # \x format
  end

  return hexFormatted.reverse.reverse.join
end

portFormatted = hexFormatPort(port)
ipFormatted = hexFormatIp(ip)

puts "IP: #{ip} is #{ipFormatted}"
puts "Port: #{port} is #{portFormatted}"

