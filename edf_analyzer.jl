include("signalweaver.jl")
using .signalweaver
using Plots
function pipeline(file_address)
    ala = read_edf(file_address)
    signal = select_signal(ala, 1)
    print(length(signal))
    @time templat = template_search(250, signal[1:20*250])
    @time rs = locate_rs(signal, templat, 0.96)
    plot_results(signal, rs, "new_plot.png", 1, 80000, (1600, 500))
end

function pipeline2(file_address)
    ala = read_edf(file_address)
    signal1 = select_signal(ala, 1)
    @time templat1 = template_search(250, signal1[1:20*250])
    @time rs1 = locate_rs(signal1, templat1, 0.96)
    signal2 = select_signal(ala, 5)
    @time templat2 = template_search(250, signal2[1:20*250])
    @time rs2 = locate_rs(signal2, templat2, 0.81)
    p1 = plot_results(signal1, rs1, "new_plot.png", 1, 80000, (1600, 500), false)
    p2 = plot_results(signal2, rs2, "new_plot.png", 1, 80000, (1600, 500), false)
    plot!(p1, p2, layout=(2, 1))
    savefig("new_double.png")
end
pipeline2("g068.EDF")