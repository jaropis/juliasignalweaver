
module signalweaver

using DataFrames
using Plots
using StatsBase
using CSV
using DataFrames
using Random
using Peaks

frequency = 200
window_length = frequency * 20 # 20 second long windows

function correlation_machine(frequency, window)
    """
       Tcorrelation_machine.
       
       This function looks for correlations inside a window within a length of template.
       
       Parameters:
       frequency - frequency of the signal in Hz
       window - the segment of signal to be analyzed
       
       Returns:
       vector with autocorrelations within the window.
      	"""
    template_length = frequency # this way we always get one second
    N = size(window, 1) - template_length
    correlations = fill(0.0, N)
    for idi in 1:N
        template = window[idi:(idi+template_length)]
        for idj in 1:N
            correlations[idj] = cor(template, window[idj:(idj+template_length)])
        end
    end
    return (correlations)
end

function plot_results(window, correlations)
    """
    plot results
    	
    Function returning two-panelled plot of the analysis - the first panel is the autocorrelations, the second is the actual signal
    Parameters:
    window - the segment of signal to be analyzed
    correlations - vector of autocorrelations within the window

    Returns:
    Plots plot
    """
    p = plot!(plot(correlations), plot(window), layout=(2, 1), show=true)
    return (p)
end

function find_good_maxima(correlations, segment_length, corr_threshold)
    maxima = []
    positions = []

    return (maxima, positions)
end

function plot_results2(window, good_maxima, offset)
    p = plot!(window, show=true, legend=false)
    scatter!(good_maxima .+ offset, window[good_maxima.+offset], marker=:circle, markersize=5, color=:red)
    return (p)
end

ecg = CSV.read("csv1.csv", DataFrame)
N = size(ecg, 1) - window_length
# beginnings of randomly selected windows
Random.seed!(777)
window_beginnings = rand(1:N, 10)

for window_idx in window_beginnings[1]
    global window = ecg[window_idx:(window_idx+window_length), :][:, 2]
    global correlations = correlation_machine(Int(frequency * 2), window)
    analyzed_vector = window .* (-1)
    threshold = 10500
    global good_maxima, vals = findmaxima(analyzed_vector)
    good_maxima = good_maxima[(analyzed_vector)[good_maxima].>threshold]
    #global good_peaks = findpeaks(window .* (-1), 1:length(window), min_prom=5000.0)
end
#plot_results(window, correlations)
plot_results2(window .* (-1), Int.(good_maxima), 0)
#print(length(window) - length(correlations))
#print(good_peaks[1] - good_maxima[1])
#print(window .* (-1))
print("\n")
print(good_maxima)
print("\n")
#print(good_peaks)
#print(window[good_maxima])
sleep(10)
end