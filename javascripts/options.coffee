$ = require('jquery')
API = require('./API')

accessToken = null

drawCurrentSong = (song) ->
  $('.option-items').html(song)

$ ->
  # Auth button click listener
  #
  # Sends message to background script to run 'vk_notification_auth' action
  #
  $('#auth').click (e) ->
    chrome.runtime.sendMessage {action: "vk_notification_auth"}, (response) ->
      if response.content is 'OK'
        $('#auth').hide()

  $('#signout').click (e) ->
    chrome.storage.local.remove 'vkaccess_token'
    $('#auth').show()

  # Show auth button if user is not authorized
  #
  chrome.storage.local.get 'vkaccess_token': {}, (items) ->
    if items.vkaccess_token.length is undefined
      $('.auth-actions').show()
      $('.option-items, #add-item').hide()
      return
    else
      accessToken = items.vkaccess_token


  chrome.storage.local.get 'current_song': {}, (items) ->
    current_song = items.current_song
    if current_song
      drawCurrentSong(current_song)
