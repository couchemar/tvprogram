"use strict"
angular.module("tv", ['tv.controllers', 'tv.services'])
.config(($routeProvider) ->
    $routeProvider
    .when(
        '/',
        controller: 'ProgramsController'
        templateUrl: 'public/templates/programs.tmpl.html'
        resolve:
            programs: ($q, $filter,
                       ChannelsStorage, ProgramsResource) ->
                checkedChannels = ChannelsStorage.get false
                fetchedRequests = []
                deferred = $q.defer()
                startDate = $filter('date')(new Date(), 'yyyy-MM-ddTHH:mm:ssZ')
                angular.forEach checkedChannels, (channel) ->
                    request = $q.defer()
                    fetchedRequests.push request.promise
                    ProgramsResource.get
                        channelId: channel._id
                        limit: 1
                        startDate: startDate
                        (data) -> request.resolve data.programs
                        () -> request.reject()

                result = []
                $q.all(fetchedRequests).then (responses) ->
                    angular.forEach responses, (response) ->
                        result.push.apply result, response
                    deferred.resolve result
                deferred.promise
    ).when(
        '/channels',
        controller: 'ChannelsController'
        templateUrl: 'public/templates/channels.tmpl.html'
        resolve:
            channels: ($q, Channels) ->
                defer = $q.defer()
                Channels.get(
                    (data) -> defer.resolve data.channels,
                    () -> defer.reject())
                defer.promise
    )
    .otherwise redirectTo: '/'
)