using HTTP
using JSON3
include("signalweaver.jl")
using Main.signalweaver

function request_handler(req)
    if req.method == "GET" && req.target == "/"
        return HTTP.Response(200, read("index.html"))
    elseif req.method == "POST" && req.target == "/calculate"
        filepath = "g068.EDF"
        edf_signal = read_edf(filepath)
        y_values = select_signal(edf_signal, 1)
        x_values = range(0, length(y_values) - 1, step=1)
        templat = template_search(250, y_values[1:20*250])
        rs = locate_rs(y_values, templat, 0.96)
        plot_results(y_values, rs, "new_plot.png", 1, 80000, (1600, 500))
        return HTTP.Response(200, JSON3.write(Dict("x" => x_values, "y" => y_values)))
    else
        return HTTP.Response(404, "Not Found")
    end
end

HTTP.serve(request_handler, "127.0.0.1", 8080)
