#!/usr/bin/ruby
=begin
networkhex.rb
Sanjiv Kawa (@skawasec)
www.popped.io
December 5, 2016

This script takes an ip address and/or port and converts it to hex
=end



ip = "127.0.0.1"
port = "9999"

# take a string and convert it to hex
def hexFormat(hex)
  hex = hex.to_i
  hex = hex.to_s(16).rjust(2, '0').scan(/.{1,2}/)

  hexFormatted = Array.new

  for element in hex
     hexFormatted.push "\\x#{element}" # \x format
  end

  return hexFormatted.reverse.join
end

# take a ip, split on . and convert it to hex
def hexFormatIp(ip)
  ipArr = Array.new

  for i in 0 .. 3
    ipArr.push ip.split(".")[i]
  end

  ipFormatted = Array.new

  for element in ipArr
     ipFormatted.push hexFormat(element)
  end

  ipFormatted.join
end

portFormatted = hexFormat(port)
ipFormatted = hexFormatIp(ip)

puts "IP: #{ip} is #{ipFormatted}"
puts "Port: #{port} is #{portFormatted}"
