controllers = angular.module('tv.controllers', [])
controllers.controller('ProgramsController', ($scope, programs) ->
    $scope.programs = programs
)

channelsController = controllers.controller('ChannelsController', ($scope, channels, ChannelsStorage) ->
    ChannelsStorage.save channels
    $scope.channels = ChannelsStorage.get true
    $scope.check = (channelId, checked) ->
        if checked
            ChannelsStorage.check channelId
        else
            ChannelsStorage.unCheck channelId
)
channelsController.resolve =
    channels: ($q, Channels) ->
        defer = $q.defer()
        Channels.get(
            (data) -> defer.resolve data.channels,
            () -> defer.reject())
        defer.promise
