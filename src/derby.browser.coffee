racer = require 'racer'
derbyModel = require './derby.Model'
Dom = require './Dom'
View = require './View'
History = require './History'
{autoRefresh} = require './refresh'
{addHttpMethods, Page} = require './router'

exports.createApp = (appModule) ->
  appExports = appModule.exports
  appModule.exports = (modelBundle, appHash, ns, ctx, appFilename) ->
    # The init event is fired after the model data is initialized but
    # before the socket object is set
    racer.on 'init', (model) ->
      view.model = model
      view.dom = dom = new Dom model, appExports
      derbyModel.init model, dom
      page = new Page view, model
      history = view.history = new History page, routes, dom
      # Ignore errors thrown when rendering; these will also be thrown
      # on the server, and throwing here causes the app not to connect
      try
        view.render model, ns, ctx, true
      catch err then

    # The ready event is fired after the model data is initialized and
    # the socket object is set
    racer.on 'ready', (model) ->
      autoRefresh view, model, appFilename, appHash

    racer.init modelBundle
    return appExports

  # Expose methods on the application module. Note that view must added
  # to both appModule.exports and appExports, since it is used before
  # the initialization function to make templates
  appModule.exports.view = appExports.view = view = new View
  routes = addHttpMethods appExports
  appExports.ready = (fn) -> racer.on 'ready', fn
  return appExports
