angular.module('app', ['ngResource'])
   .config(['$httpProvider', function($httpProvider) {
       $httpProvider.defaults.headers.common['Origin'] = '*';
    }])
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