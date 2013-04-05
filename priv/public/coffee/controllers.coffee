controllers = angular.module('tv.controllers', [])
.controller('ProgramsController', ($scope, programs) ->
    $scope.programs = programs
)
.controller('ChannelsController', ($scope, channels, ChannelsStorage) ->
    ChannelsStorage.save channels
    $scope.channels = ChannelsStorage.get true
    $scope.check = (channelId, checked) ->
        if checked
            ChannelsStorage.check channelId
        else
            ChannelsStorage.unCheck channelId
)
