angular.module('app', ['ngResource'])
.controller('MainController', function($scope, $resource, $log) {
     $resource('http://localhost\\:9090/program/:channel_id').get(
         {channel_id: 1,
          limit: 10},
         function(data) {
             $log.info(data);
             $scope.programs = data.programs;
         },
         function(reason) {
             $log.info(reason);
         }
     )
})
