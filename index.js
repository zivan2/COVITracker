function Graph(graphX, graphY, label, data) {
    return {
        type: "scatter",
        data: {
            datasets: [{
                label: label,
                data: data,
                pointBackgroundColor: "rgba(0,0,0,1)"
            }]
        },
        options: {
            hover: {
                animationDuration: 0
            },
            responsive:true,
            maintainAspectRatio: false,
            scales: {
                yAxes: [{
                    scaleLabel: {
                        display: true,
                        labelString: graphY
                    }
                }],
                xAxes: [{
                    scaleLabel: {
                        display: true,
                        labelString: graphX
                    }
                }]
            }
        }
    };
}
let stateName = 'ca';
fetch('https://covidtracking.com/api/v1/states/' + stateName + '/daily.json').then(resp => {
    resp.json().then((data) => {
        for (let i = 0; i < data.length; i++) {
            let date = data[i].date.toString();
            data[i].date = {
                year: date.substring(0, 4),
                month: date.substring(4, 6),
                day: date.substr(6, 8)
            };
            let plotData = [];
            for (let i = 0; i < data.length; i++) {
                plotData.push({
                    x: i+1,
                    y: data[i].positive
                });
            }
            let graphX = 'time', graphY = 'cases';
            const context = document.getElementById("chart");
            let chart = new Chart(
                context, new Graph(graphX, graphY, `${graphY} against ${graphX}`, plotData)
            );
        }
    }).catch(err => console.error(err));
});