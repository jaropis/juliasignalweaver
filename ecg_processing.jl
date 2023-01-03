
module signalweaver

using DataFrames
using Plots
using StatsBase
using CSV
using DataFrames
using Random
using Findpeaks

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
    for i in segment_length:(length(correlations)-segment_length)
        position = i + segment_length - 1
        segment = correlations[i:position]
        max_in_segment = findmax(segment)
        #print(max_in_segment)
        #print("\n")
        max_position = (i + max_in_segment[2])
        if (max_position != i) && (max_position != position) && !(max_position in positions) && max_in_segment[1] >= corr_threshold
            #print("i + position + max_position + max_in_segment[2] ")
            #print(i)
            #print(" ")
            #print(position)
            #print(" ")
            #print(max_position)
            #print(" ")
            #print(max_in_segment[2])
            #print("\n")
            push!(maxima, max_in_segment[1])
            push!(positions, max_position)
        end
    end
    return (maxima, positions)
end

function plot_results2(window, correlations, good_maxima, offset)
    p = plot!(window, show=true)
    scatter!(good_maxima[2] .- offset, window[good_maxima[2].-offset], marker=:circle, markersize=5, color=:red)
    return (p)
end

ecg = CSV.read("csv1.csv", DataFrame)
N = size(ecg, 1) - window_length
# beginnings of randomly selected windows
Random.seed!(777)
window_beginnings = rand(1:N, 10)

for window_idx in window_beginnings[1]
    global window = ecg[window_idx:(window_idx+window_length), :][:, 2]
    global correlations = correlation_machine(frequency, window)
    global good_maxima = find_good_maxima(correlations, Int(frequency / 2), 0.7)
end
plot_results(window, correlations)
plot_results2(window, correlations, good_maxima, Int(62))
sleep(20)
end