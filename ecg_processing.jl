
module signalweaver

using DataFrames
using Plots
using StatsBase
using CSV
using Random
using ImageFiltering

# setup
frequency = 200 # 200 for ecg
window_length = frequency * 5 # 5 second long windows
data_index = 2 # 2 for ecg
savefilename = "ecg_template.png"
datafilename = "csv1.csv"
dpi = 300
linewidth = 3

# functions
function template_search(frequency, window)
    """
    Template search.

    This function looks repeating shape.

    Parameters:
    frequency - frequency of the signal in Hz
    window - the segment of signal to be analyzed

    Returns:
    vector with autocorrelations within the window.
        """
    if (isodd(frequency))
        error("frequency needs to be an even number")
    end
    template_length = frequency + 1 # 100 + 1 for the kernel (for now)
    N = size(window, 1) - template_length
    template = fill(0.0, template_length)
    current_corr_sum = 0
    ker = ImageFiltering.Kernel.gaussian((div(frequency, 4),))
    kernel = fill(0.0, template_length)
    bound = (length(ker) - 1) / 2 |> Int
    # refactor the loop below
    for i in -1*(bound-1):(bound+1)
        kernel[i+div(frequency, 2)] = ker[i-1]
    end
    for idi in 1:N
        segment = window[idi:(idi+template_length-1)] .* kernel
        for idj in 1:N
            corsum = cor(segment, window[idj:(idj+template_length-1)]) |> sum
            if corsum > current_corr_sum
                template = window[idj:(idj+template_length-1)]
                current_corr_sum = corsum
            end
        end
    end
    return (template)
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

function plot_results2(window, good_maxima, offset)
    p = plot!(window, show=true, legend=false)
    scatter!(good_maxima .+ offset, window[good_maxima.+offset], marker=:circle, markersize=5, color=:red)
    return (p)
end

# reading data
ecg = CSV.read(datafilename, DataFrame)
N = size(ecg, 1) - window_length
# beginnings of randomly selected windows
#Random.seed!(777)
window_beginnings = rand(1:N, 10)

# main loop
for window_idx in window_beginnings[1]
    global window = ecg[window_idx:(window_idx+window_length), :][:, data_index]
    global template = template_search(Int(frequency), window)
end
plot!(template, show=true, legend=false, dpi=dpi, linewidth=linewidth)
savefig(savefilename)
end