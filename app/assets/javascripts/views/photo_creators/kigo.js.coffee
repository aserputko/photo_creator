class PhotoCreator.Views.Kigo extends Backbone.View

	template: JST['photo_creators/kigo']

	initialize: () ->
    @model = new PhotoCreator.Models.Kigo()
    @model.on("sync", @render, @)
    @model.on("change", @render, @)

  render: ->
    $(@el).html(@template(@model.toJSON()))
    this

  events: {
    "click #adv" : "searchAccount",
    "click #back": "back",
    "click #download" : "download"
  }

  searchAccount: (event) ->
    event.preventDefault()
    advertiser = $('#advertiser').val()
    brand = $('#brand option:selected').val()
    @model.save({ advertiser: advertiser, brand : brand }, {error: @advertiserNotFound, silent: true})

  advertiserNotFound: -> alert 'Advertiser Not Found'

  back: ->
    @model.set(@model.defaults)

  download: ->
    photoCreator = new PhotoCreator.Models.PhotoCreator
    photoCreator.save(@model.toJSON(), {
      success: (model, response) -> window.location.pathname = response.url}
    )
