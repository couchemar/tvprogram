angular.module('app', ['ngResource'])
.controller('MainController', function($scope, $resource, $log) {
     $resource('http://localhost\\:9090/program').get(
         {},
         function(data) {
             $log.info(data);
         },
         function(reason) {
             $log.info(reason);
         }
     )
})
