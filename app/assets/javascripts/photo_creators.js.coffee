window.PhotoCreator =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: ->
  	new PhotoCreator.Routers.PhotoCreators()

$(document).ready ->
  PhotoCreator.init()
  Backbone.history.start()