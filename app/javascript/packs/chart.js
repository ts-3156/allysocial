export class Chart {
  constructor(id, categories, series) {
    this.id = id;
    this.categories = categories;
    this.series = series;
  }

  draw() {
    this.instance = Highcharts.chart(this.id, {
      chart: {
        type: 'bar'
      },
      title: null,
      subtitle: null,
      xAxis: {
        categories: this.categories,
        title: {
          text: null
        }
      },
      yAxis: {
        min: 0,
        title: null,
        labels: {
          overflow: 'justify'
        }
      },
      tooltip: {
        enabled: false
      },
      plotOptions: {
        bar: {
          dataLabels: {
            enabled: true
          }
        }
      },
      legend: {
        enabled: false
      },
      credits: {
        enabled: false
      },
      series: [{
        data: this.series
      }]
    });
  }

  destroy() {
    this.instance.destroy();
  }
}

