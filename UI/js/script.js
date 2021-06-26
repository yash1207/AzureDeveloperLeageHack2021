// Code goes here
(() => {
  angular
  .module('dateRangeDemo', ['ui.bootstrap', 'rzModule'])
  .controller('dateRangeCtrl', function dateRangeCtrl($scope) {
    var vm = this;

    // Single Date Slider    
    var dates = [];
    for (var i = 1; i <= 400; i++) {
      dates.push(new Date(2020, 4, i));
    }
    $scope.slider_dates = {
      value: new Date(2020, 7, 15),
      options: {
        stepsArray: dates,
        translate: function(date) {
          if (date !== null)
            return date.toDateString();
          return '';
        }
      }
    };
    
    // Date Range Slider
    var floorDate = new Date(2020, 0, 1).getTime();
    var ceilDate = new Date(2021, 4, 12).getTime();
    var minDate = new Date(2021, 1, 10).getTime();
    var maxDate = new Date(2021, 4, 12).getTime();
    var millisInDay = 24*60*60*1000;
      


    var monthNames =
    [
      "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
    ];

    var formatDate = function (date_millis)
    {
      var date = new Date(date_millis);
      return date.getDate()+"-"+monthNames[date.getMonth()]+"-"+date.getFullYear();
    }


    //Range slider config 
    $scope.dateRangeSlider = {
      minValue: minDate,
      maxValue: maxDate,
      options: {
        floor: floorDate,
        ceil: ceilDate,
        step: millisInDay,
        showTicks: false,
        draggableRange: true,
        translate: function(date_millis) {
          if ((date_millis !== null)) {
            var dateFromMillis = new Date(date_millis);
            // console.log("date_millis="+date_millis);
            // return dateFromMillis.toDateString();
            return formatDate(dateFromMillis);
          }
          return '';
        }
      }
    };
    
  });
})();
