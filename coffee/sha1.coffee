##

Implementation of SHA-1 in coffeescript

##

#Constants
charSize = 8

# Convert a String into an array of big-endian words
stringToBinary = (str) ->
  result = []
  i = 0
  while i < str.length
    index = Math.floor(i / 4)
    result[index] |= (str.charCodeAt(i) & 255) << (24 - 8*(i%4))
    i += 1
  result

# Convert an array of bytes ino a string
binaryToStr = (binary) ->
  str = ""
  tab = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

