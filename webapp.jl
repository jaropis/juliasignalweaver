using Stipple

@reactive mutable struct Name <: ReactiveModel
    name::R{String} = "World!"
end

function ui(model)
    page(
        model,
        class="container",
        [
            h1([
                "Hello "
                span("", @text(:name))
            ])p([
                "What is your name? "
                input("", placeholder="Type your name", @bind(:name))
            ])
        ]
    )
end

route("/") do
    model = Name |> init
    html(ui(model), context=@__MODULE__)
end