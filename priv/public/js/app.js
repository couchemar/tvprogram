"use strict";
angular.module('app', ['ngResource'])
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
.controller('ChannelsController', function($scope,  channels,
                                           ChannelsStorage) {
    ChannelsStorage.save(channels);
    $scope.channels = ChannelsStorage.get(true);

    $scope.check = function(channelId, checked) {
        if (checked) {
            ChannelsStorage.check(channelId);
        } else {
            ChannelsStorage.unCheck(channelId);
        }
    };
})
.controller('ProgramsController', function($scope, programs) {
    $scope.programs = programs;

})
.factory('Channels', function($resource) {
    var Channels = $resource(
        'http://localhost\\:9090/channel/'
    );
    return Channels;
})
.factory('ChannelsStorage', function($window, $filter, Channels) {
    var _save = function(channels) {
            $window.localStorage['channels'] = JSON.stringify(channels);
    };

    var _getChecked = function(channels) {
        var _checked = $window.localStorage['channels.checked'];
        return !!_checked ? JSON.parse(_checked) : [];
    };

    var _getChannels = function() {
        var channels = JSON.parse($window.localStorage['channels']);
        var checked = _getChecked();
        angular.forEach(channels, function(channel) {
            if (checked.indexOf(parseInt(channel._id)) != -1) {
                channel.checked = true;
            }
        });
        return channels;
    };

    return {
        save: _save,
        get: function(all) {
            var channels = _getChannels();
            if (!!all) {
                return channels;
            } else {
                return $filter('filter')(channels, {checked: true});
            }
        },
        check: function(channelId) {
            var checked = _getChecked();
            if (checked.indexOf(channelId) == -1) {
                checked.push(parseInt(channelId));
                $window.localStorage['channels.checked'] = JSON.stringify(checked);
            }
        },
        unCheck: function(channelId) {
            var checked = _getChecked();
            var idx = checked.indexOf(parseInt(channelId));
            if (idx > -1) {
                checked.splice(idx, 1);
                $window.localStorage['channels.checked'] = JSON.stringify(checked);
            }
        }
    };
})
.factory('ProgramsResource', function($resource){
    var Programs = $resource(
        'http://localhost\\:9090/channel/:channelId/program/',
        {channelId: '@channelId'}
    );
    return Programs;
});
