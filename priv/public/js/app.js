angular.module('app', ['ngResource'])
.controller('MainController', function($scope, $log,
                                       ProgramsResource, Channels,
                                       Programs, ChannelsStorage) {

    var prepareChannel = function(channelId) {
        ProgramsResource.get(
            {channelId: channelId,
             limit: 1},
            function(data) {
                $log.info(data);
                Programs.save(data.programs);
            },
            function(reason) {
                $log.info(reason);
            }
        );
    };

    var prepareChannels = function(channels) {
        angular.forEach(channels, function(channel) {
            prepareChannel(channel._id);
        });
    };

    Channels.get(function(data) {
        ChannelsStorage.save(data.channels);
        $scope.channels = ChannelsStorage.get(true);
        prepareChannels(ChannelsStorage.get(false));
    });

    $scope.$watch(ChannelsStorage.get, function(newValue, oldValue) {
        if (oldValue == newValue) {
            return;
        }
        $scope.channels = newValue;
    }, true);

    $scope.$watch(Programs.get, function(newValue, oldValue) {
        if (oldValue == newValue) {
            return;
        }
        $scope.programs = newValue;
    }, true);

    $scope.check = function(channelId, checked) {
        if (checked) {
            ChannelsStorage.check(channelId);
            prepareChannel(channelId);
        } else {
            ChannelsStorage.unCheck(channelId);
            Programs.removeByChannelId(channelId);
        }
    };
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

    Channels.get(function(data) {
        _save(data.channels);
    });

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
.factory('Programs', function($filter) {
    var programs = [];
    return {
        get: function() {
            return programs;
        },
        save: function(_programs) {
            programs.push.apply(programs, _programs);
        },
        removeByChannelId: function(channelId) {
           programs = $filter('filter')(
                programs, function(program) {
                    if (program.channel_id != channelId) {
                        return true;
                    }
                    return false;
                });
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
