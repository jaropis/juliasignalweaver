class ECGplot {
    constructor() {
        this.oberver_present = false;
        this.click_event = document.addEventListener("DOMContentLoaded", function () {
            const submitButton = document.getElementById("submit");
            submitButton.addEventListener("click", updatePlot);
        });
        this.ecgPlotDiv = null;
    }

    createPlot(x, y, pointsX, pointsY) {
        const ecgTrace = {
            x: x,
            y: y,
            mode: 'lines',
            type: 'scattergl',
            line: { shape: 'spline' },
            hoverinfo: 'none'
        };

        const annotsTrace = {
            x: pointsX,
            y: pointsY,
            mode: 'markers',
            type: 'scattergl',
            marker: {
                size: 8, // You can adjust the size of the markers
                color: 'red' // You can choose a color for the markers
            },
            hoverinfo: 'x+y' // You can customize the hoverinfo here or set it to 'none' if you don't want any tooltips
        };
        const data = [ecgTrace, annotsTrace];
        const layout = {
            showlegend: false,
            xaxis: {
                range: [0, 20000],
                showgrid: false,
                zeroline: false,
                showline: false,
                autotick: true,
                ticks: '',
                showticklabels: false
            },
            yaxis: {
                //range: [-16000, 16000],
                autorange: true,
                showgrid: false,
                zeroline: false,
                showline: false,
                autotick: true,
                ticks: '',
                showticklabels: false
            }
        }

        Plotly.newPlot('plot', data, layout);
        if (!this.oberver_present) {
            this.ecgPlotDiv = document.getElementById('plot');
            this.ecgPlotDiv.on('plotly_click', function (data) {
                var pointIndex = data.points[0].pointNumber;
                var traceIndex = data.points[0].curveNumber;
                console.log("ale plot!!!")
                console.log(data)
                if (traceIndex === 0) {
                    initialColorsBlue[pointIndex] = 'red';

                    var update = {
                        marker: { color: initialColorsBlue }
                    };

                    Plotly.update('scatterPlot', update, {}, [traceIndex]);
                }
            });
            this.oberver_present = true;
        }
    }

    updatePlot() {
        const xhr = new XMLHttpRequest();
        xhr.open("POST", "/calculate", true);
        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4 && xhr.status === 200) {
                const response = JSON.parse(xhr.responseText);
                createPlot(response.x, response.y, response.pointsX, response.pointsY);
            }
        };
        xhr.send();
    }
}
