# contents = File.read("song_list_raw.txt")
# lines = contents.split("\n")

lines = File.readlines("song_list_raw.txt")

# Here is what `lines` looks like at the moment...
#
# ["\"A Song I Heard the Ocean Sing\" [3]\n",
# "\"AC/DC Bag\" [4]\n",
# "\"Access Me\" [5]\n",
# "\"Acoustic Army\" (Also known as The Real Taste of Licorice) [6]\n",
# "\"Aftermath\" (never played live) [7]\n",
# ...]

songs = []

lines.each do |line|
  song = line.split("\"")[1]
  songs << song
end

# is equivalent to:
#
# songs = lines.map do |line|
#   line.split("\"")[1]
# end
