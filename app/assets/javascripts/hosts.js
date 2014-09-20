

    function drawChart(div,data) {



        var options = {
            width: 400, height: 120,
            redFrom: 90, redTo: 100,
            yellowFrom:75, yellowTo: 90,
            minorTicks: 5
        };

        var chart = new google.visualization.Gauge(document.getElementById(div));

        chart.draw(data, options);
    }