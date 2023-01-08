include("signalweaver.jl")
using .signalweaver
ala = read_edf("g068.EDF")
signal = select_signal(ala, 1)
templat = template_search(250, signal)
rs = locate_rs(signal, templat, 0.95)
print(length(signal))
plot_results(signal, rs, "new_plot.png", 1, 20000)