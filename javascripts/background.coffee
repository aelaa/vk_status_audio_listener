_ = require('lodash')
API = require('./API')
Promise = require('es6-promise').Promise

onLive = 0

badgeText = (resp) ->
  if resp.aid
    return "!"
  else
    return ""


# updatePosts = (fn) ->
updateLouchanxxStatus = (fn) ->
  chrome.storage.local.get 'vkaccess_token': {}, (items) ->
    requestPromises = []
    token = items.vkaccess_token

    if token.length isnt undefined
      key = 228878407
      url = API.requestUrl('status.get', { user_id: key, access_token: token })

      fetch(url).then((response) ->
        response.json()
      ).then((data) ->
        resp = data.response

        if resp.audio
          chrome.storage.local.set {'current_song': resp.audio.id}
          fn(resp.audio)
        else
          fn(resp)
      )

getUrlParameterValue = (url, parameterName) ->
  urlParameters  = url.substr(url.indexOf("#") + 1)
  parameterValue = ""

  urlParameters = urlParameters.split("&")

  for param in urlParameters
    temp = param.split("=")

    return temp[1] if temp[0] is parameterName

  parameterValue


listenerHandler = (authenticationTabId) ->
  tabUpdateListener = (tabId, changeInfo) ->
    if tabId is authenticationTabId and changeInfo.url isnt undefined and changeInfo.status is "loading"
      if changeInfo.url.indexOf('oauth.vk.com/blank.html') > -1
        authenticationTabId = null
        chrome.tabs.onUpdated.removeListener(tabUpdateListener)

        vkAccessToken = getUrlParameterValue(changeInfo.url, 'access_token')

        if vkAccessToken is undefined or vkAccessToken.length is undefined
          displayAnError('vk auth response problem', 'access_token length = 0 or vkAccessToken == undefined')
          return

        vkAccessTokenExpiredFlag = Number(getUrlParameterValue(changeInfo.url, 'expires_in'))

        if vkAccessTokenExpiredFlag isnt 0
          displayAnError('vk auth response problem', 'vkAccessTokenExpiredFlag != 0' + vkAccessToken)
          return

        chrome.storage.local.set {'vkaccess_token': vkAccessToken}, ->
          chrome.tabs.remove tabId


# stage3
chrome.alarms.onAlarm.addListener (alarm)->
  if alarm.name is 'update_louchanxx_status'
    updateLouchanxxStatus (resp) ->
      chrome.browserAction.setBadgeText({text: badgeText(resp)})

# stage1
chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  if request.action is "vk_notification_auth"
    vkClientId           = '5420452'
    vkRequestedScopes    = 'offline,status'
    vkAuthenticationUrl  = "https://oauth.vk.com/authorize?client_id=#{vkClientId}&scope=#{vkRequestedScopes}&redirect_uri=http%3A%2F%2Foauth.vk.com%2Fblank.html&display=page&response_type=token"

    chrome.tabs.create {url: vkAuthenticationUrl, selected: true}, (tab) ->
      chrome.tabs.onUpdated.addListener(listenerHandler(tab.id))

    sendResponse({content: "OK"})

  if request.action is "open_options_page"
    optionsUrl = chrome.extension.getURL('options.html')

    chrome.tabs.query url: optionsUrl, (tabs)->
      if tabs.length
        chrome.tabs.update tabs[0].id, active: true
      else
        chrome.tabs.create url: optionsUrl
    sendResponse({content: 'OK'})

  if request.action is "notification_list"
    updateLouchanxxStatus (data)->
      sendResponse({content: 'OK', data: data})
  true

#stage2
chrome.runtime.onInstalled.addListener ->
  chrome.alarms.create "update_louchanxx_status",
    when: Date.now() + 1000
    periodInMinutes: 1.0
