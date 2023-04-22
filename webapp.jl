using HTTP
using JSON3
include("signalweaver.jl")
using Main.signalweaver

function request_handler(req)
    if req.method == "GET"
        print(req.target)
        if req.target == "/"
            print("index.html\n")
            return HTTP.Response(200, read("index.html", String))
        elseif req.target == "/signalweaver.js"
            print("js\n")
            return HTTP.Response(200, read("signalweaver.js", String))
        else
            # Return a 404 Not Found response for other requests
            return HTTP.Response(404, "Not Found")
        end
        return HTTP.Response(200, read("index.html"))
    elseif req.method == "POST" && req.target == "/calculate"
        segment_length = 20000
        y_offset = 1150
        filepath = "g068.EDF"
        edf_signal = read_edf(filepath)
        y_values = select_signal(edf_signal, 1)
        x_values = range(0, length(y_values) - 1, step=1)
        templat = template_search(250, y_values[1:20*250])
        rs = locate_rs(y_values, templat, 0.96, 0.33)
        pointsX = rs[rs.<=x_values[segment_length]]
        return HTTP.Response(200, JSON3.write(
            Dict(
                "x" => x_values[1:segment_length],
                "y" => y_values[1:segment_length],
                "pointsX" => pointsX,
                "pointsY" => y_values[pointsX] .+ y_offset)))
    else
        return HTTP.Response(404, "Not Found")
    end
end

HTTP.serve(request_handler, "127.0.0.1", 8080)
