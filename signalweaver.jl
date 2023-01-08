module signalweaver

using DataFrames
using Plots
using StatsBase
using Random
using ImageFiltering
using EDF
export read_edf, template_search, locate_rs, plot_results, describe_edf_signal, select_signal
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

locate_rs = function (ecg, template, detection_threshold)
    rs = []
    local_segment = fill(0, length(template))
    in_max = false
    match_begin = 0
    match_end = 0
    match_length = []
    window_length = length(template)
    for idx in 1:(length(ecg)-length(template)+1)
        local_correlation = cor(template, ecg[idx:(idx+length(template)-1)])
        if (local_correlation > detection_threshold)
            if !in_max
                match_begin = idx
                in_max = true
            end
            push!(local_segment, idx)
        elseif in_max
            in_max = false
            match_end = idx
            if match_end + window_length < length(ecg)
                match_window = ecg[(match_begin):(match_end+window_length)] # window over which we found mathing template with respect to detection_threshold
            else
                break
            end
            push!(rs, match_begin + argmax(match_window))
            local_segment .= 0
            match_begin = 0
            match_end = 0
            push!(match_length, length(match_window))
        end
    end
    return (rs)
end

function plot_results(window, good_maxima, filename, min, max)
    """
    plot results
        
    Function returning two-panelled plot of the analysis - the first panel is the autocorrelations, the second is the actual signal
    Parameters:
    window - the segment of signal to be analyzed
    good_maxima - positions of maxima
    filename - name of file where to save



    Returns:
    Plots plot
    """
    x = good_maxima[good_maxima.>min.&&good_maxima.<=max]
    markers_x = x .- min
    markers_y = window[x.-1]
    y = window[min:max]
    plot!(y, show=true, legend=false)
    scatter!(markers_x, markers_y, marker=:circle, markersize=5, color=:red)
    savefig(filename)
end

function read_edf(filepath)
    data = EDF.read(filepath)
    data.signals
end

function select_signal(edf_signal, edf_signal_idx)
    return ((edf_signal[edf_signal_idx]).samples)
end

function describe_edf_signal(edf_signal)
    idx = 1
    for sigdx in edf_signal
        print(idx, ") ")
        print(sigdx.header)
        print("\n")
    end
end
end