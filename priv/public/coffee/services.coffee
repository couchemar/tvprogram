angular.module('tv.services', ['ngResource'])
.factory('Channels', ($resource) ->
    $resource 'http://localhost\\:9090/channel/')
.factory('ProgramsResource', ($resource) ->
    $resource 'http://localhost\\:9090/channel/:channelId/program/',
        channelId: '@channelId')