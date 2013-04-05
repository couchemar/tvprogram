"use strict";
angular.module('app', ['ngResource',
                       'tv.controllers',
                       'tv.services'])
.config(function($routeProvider) {
    $routeProvider
        .when('/', {
            controller: 'ProgramsController',
            templateUrl: 'public/templates/programs.tmpl.html',
            resolve: {
                programs: function($q,
                                   ChannelsStorage,
                                   ProgramsResource) {
                    var checkedChannels = ChannelsStorage.get(false);
                    var fetchedRequests = [];

                    var deferred = $q.defer();
                    angular.forEach(checkedChannels, function(channel) {
                        var request = $q.defer();
                        fetchedRequests.push(request.promise);
                        ProgramsResource.get(
                            {channelId: channel._id,
                             limit: 1},
                             function(data) {
                                 request.resolve(data.programs);
                             },
                             function() {
                                 request.reject();
                             }
                        );

                    });
                    var result = [];
                    $q.all(fetchedRequests).then(function(responses) {
                        angular.forEach(responses, function(response) {
                            result.push.apply(result, response);
                        });
                        deferred.resolve(result);
                    });
                    return deferred.promise;
                }
            }
        })
        .when('/channels', {
            controller: 'ChannelsController',
            templateUrl: 'public/templates/channels.tmpl.html',
            resolve: {
                channels: function($q, Channels, $log) {
                    var defer = $q.defer();
                    Channels.get(
                        function(data) {
                            defer.resolve(data.channels);
                        },
                        function() {
                            defer.reject();
                        });
                    return defer.promise;
                }
            }
        })
        .otherwise({redirectTo: '/'});
})
