class PhotoCreator.Routers.PhotoCreators extends Backbone.Router

	routes: {
    ''				: 'home',
    'kigo'		: 'kigo',
    'ha-xml'	: 'ha_xml'
  }

  home: ->
  	$('#content').html("<h1>HOME</h1>")

  kigo: ->
  	view = new PhotoCreator.Views.Kigo()
  	$('#content').html(view.render().el)

  ha_xml: ->
  	$('#content').html("<h1>HA-XML</h1>")