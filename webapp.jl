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
        return HTTP.Response(200, JSON3.write(Dict("x" => x_values, "y" => y_values)))
    else
        return HTTP.Response(404, "Not Found")
    end
end

HTTP.serve(request_handler, "127.0.0.1", 8080)
