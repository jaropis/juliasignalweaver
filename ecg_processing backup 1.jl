import CSV
using DataFrames
using Plots
using StatsBase
frequency = 200
window_length = frequency * 10 # roughly 10s of recordings
ecg = CSV.read("AVA02_2017-01-18.csv", DataFrame)
starting_point = rand(1:(length(ecg[:, 1])-10)) # random starting point
# now plot ecg in window
plot(ecg[starting_point:(starting_point+window_length), :][:, 1], ecg[starting_point:(starting_point+window_length), :][:, 2])