angular.module('app', ['ngResource'])
.controller('MainController', function($scope, $log,
                                       ProgramsResource, Channels,
                                       Programs) {
    Channels.get(function(data) {
        $scope.channels = data.channels;
    });
    $scope.$watch(Programs.get, function(newValue, oldValue) {
        if (oldValue == newValue) {
            return;
        }
        $scope.programs = newValue;
    }, true);

    $scope.check = function(channelId, checked) {
        if (checked) {
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
        } else {
            Programs.removeByChannelId(channelId);
        }
    };
})
.factory('Channels', function($log, $resource) {
    var Channels = $resource(
        'http://localhost\\:9090/channel/'
    );
    return Channels;
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
