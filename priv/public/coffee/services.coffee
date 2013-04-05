angular.module('tv.services', ['ngResource'])
.factory('Channels', ($resource) ->
    $resource 'http://localhost\\:9090/channel/')
.factory('ProgramsResource', ($resource) ->
    $resource 'http://localhost\\:9090/channel/:channelId/program/',
        channelId: '@channelId')
.factory('ChannelsStorage', ($window, $filter) ->
    _save = (channels) ->
        $window.localStorage.channels = JSON.stringify channels
    _getChecked = () ->
        checked = $window.localStorage['channels.checked']
        if !!checked then JSON.parse checked else []

    _getChannels = () ->
        channels = JSON.parse $window.localStorage.channels
        checked = _getChecked()
        angular.forEach channels, (channel) ->
            if checked.indexOf(parseInt(channel._id)) != -1
                channel.checked = true
        channels
    storage =
        save: _save,
        get: (all=false) ->
            channels = _getChannels()
            if all
                channels
            else
                $filter('filter') channels, checked: true
        check: (channelId) ->
            checked = _getChecked()
            if checked.indexOf(channelId) == -1
                checked.push parseInt channelId
                $window.localStorage['channels.checked'] = JSON.stringify checked
        unCheck: (channelId) ->
            checked = _getChecked()
            idx = checked.indexOf parseInt channelId
            if idx > -1
                checked.splice idx, 1
                $window.localStorage['channels.checked'] = JSON.stringify checked
)