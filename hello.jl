module PlotsOnAnotherModule

import Plots

function foo()
    p = Plots.plot!([1.0, 2, 3, 4, 6, 8, 10], show=true)
end

foo() # This is the call that creates the plot
sleep(20)
end