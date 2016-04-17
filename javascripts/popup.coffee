$ = require('jquery')

# $(document).on 'click', 'a', (e) ->
#   chrome.tabs.create {url: $(this).attr('href'), selected: true}

#   e.preventDefault()

$ ->
  chrome.storage.local.get 'vkaccess_token': {}, (items) ->
    if items.vkaccess_token.length is undefined
      $('#auth').show()
      return

    chrome.runtime.sendMessage {action: "notification_list", token: items.vkaccess_token}, (response) ->
      $('#notifications').html("")
      if response.data.aid
        $('#notifications').append($('<p />', {text: 'louchan is streaming:'}))
        $('#notifications').append($('<a />', {class: 'audio-link', href: "https://vk.com/id228878407", text: response.data.performer + " - " + response.data.title }))
      else
        $('#notifications').append($('<p />', {text: 'louchan is not streaming now. She says:'}))
        $('#notifications').append($('<p />', {class: 'status', text: response.data.text}))

  $('#auth').click (e) ->
    chrome.runtime.sendMessage {action: "vk_notification_auth"}

    e.preventDefault()

  $('#settings').click (e) ->
    chrome.runtime.sendMessage {action: "open_options_page"}

    e.preventDefault()
