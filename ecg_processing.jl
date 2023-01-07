# using BenchmarkTools
using CSV
using DataFrames
include("signalweaver.jl")
using .signalweaver
# setup
frequency = 200 # 200 for ecg
window_length = frequency * 5 # 5 second long windows
data_index = 2 # 2 for ecg
savefilename = "ecg_template.png"
datafilename = "csv1.csv"
result_filename = "detected.png"
dpi = 300
linewidth = 3
detection_threshold = 0.6

# functions
# reading data
ecg = CSV.read(datafilename, DataFrame)
N = size(ecg, 1) - window_length
# beginnings of randomly selected windows
#Random.seed!(777)
window_beginnings = rand(1:N, 10)

# main loop
for window_idx in window_beginnings[1]
    global window = ecg[window_idx:(window_idx+window_length), :][:, data_index]
    print("finding template\n")
    global template = template_search(Int(frequency), window)
end
#plot!(template, show=true, legend=false, dpi=dpi, linewidth=linewidth)
#savefig(savefilename)
print("looking for rs\n")
rs = locate_rs(ecg[:, data_index], template, detection_threshold)
plot_results(ecg[:, 2], rs, result_filename, 900 * frequency, 910 * frequency)
