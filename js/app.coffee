App = Ember.Application.create()

App.Router.map ->
  @resource('about')
  @resource('vmguests', ->
    @resource('vmguest', {path: '/:vmguest_name'})
  )
  @resource('configitems', ->
    @resource('configitem', {path: '/:configitem_name'})
  )
  @resource('hsns', ->
    @resource('hsn', {path: '/:hsn_name'})
  )


App.HsnsRoute = Ember.Route.extend
  model:  ->
    #console.log 'in VmguestsRoute model'
    hsns = App.Hsn.all()

App.HsnRoute = Ember.Route.extend
  model: (params) ->
    hsn = App.Hsn.find(params.hsn_name)
  serialize: (model) ->
    hsn_name: model.name.replace(new RegExp(" ", "g"), "_")

App.ConfigitemsRoute = Ember.Route.extend
  model: ->
    configItems = App.Configitem.all()

App.ConfigitemRoute = Ember.Route.extend
  model: (params) ->
    configItem = App.Configitem.find(params.configitem_name)
  serialize: (model) ->
    configitem_name: model.full_node_name

App.VmguestsRoute = Ember.Route.extend
  model:  ->
    #console.log 'in VmguestsRoute model'
    vms = App.Vmguest.all()

App.VmguestRoute = Ember.Route.extend
  model: (params) ->
    #console.log 'in VmguestRoute model using name ' + params.vmguest_name
    vm = App.Vmguest.find(params.vmguest_name)
    return vm
  serialize: (model) ->
    vmguest_name: model.full_node_name
  # setupController: (controller, model) ->
  #   console.log 'in VmguestRoute setupcontroller'
  #   console.log 'controller is...' + controller
  #   console.log 'model is...' + model
  #   controller.set('content', model)

App.Vmguest = Ember.Object.extend
  full_node_name: ""
  # stuff: "Hello there!"

App.Vmguest.reopenClass
  all: ->
    #console.log 'in Vmguest all'
    json_url = "http://localhost:7474/db/data/label/vmwareGuest/nodes"
    vms = [] # create an empty array to be returned
    return $.getJSON(json_url).then ((response) ->
      #console.log 'in Vmguest all json processor'     
      response.forEach( (item) ->
        #console.log 'got json name ' + item.data['name']
        vms.push( App.Vmguest.create( item.data ))
      )
      return vms #return from the then function
    )

  find: (name) ->
    console.log name
    json_url = "http://localhost:7474/db/data/label/vmwareGuest/nodes?full_node_name=%22" + name + "%22"
    console.log json_url
    return $.getJSON(json_url).then ( (response) ->
      console.log 'in Vmguest find'
      console.log 'json: ' + response
      $.each(response, (i, item) ->
        console.log item['data']
      )
      console.log response[0]['data']['full_node_name']
      vm = App.Vmguest.create(response[0]['data']) 
      return vm
    )
App.Configitem = Ember.Object.extend
  full_node_name: ""

App.Configitem.reopenClass
  all: ->
    json_url = "http://localhost:7474/db/data/label/ci/nodes"
    cis = [] # create an empty array to be returned
    return $.getJSON(json_url).then ((response) ->
   
      response.forEach( (item) ->
        cis.push( App.Configitem.create( item.data ))
      )
      return cis #return from the then function
    )

  find: (name) ->
    json_url = "http://localhost:7474/db/data/label/ci/nodes?full_node_name=%22" + name + "%22"
    return $.getJSON(json_url).then ( (response) ->
      vm = App.Configitem.create(response[0]['data']) 
      return vm
    )
App.Hsn = Ember.Object.extend
  name: ""

App.Hsn.reopenClass
  all: ->
    json_url = "http://localhost:7474/db/data/label/hsn/nodes"
    hsns = [] # create an empty array to be returned
    return $.getJSON(json_url).then ((response) ->
   
      response.forEach( (item) ->
        hsns.push( App.Hsn.create( item.data ))
      )
      return hsns #return from the then function
    )

  find: (name) ->
    # Cypher query to find components of HSN
    # - probably not what we should do here 
    # - this is more of a hsn_component object, not an hsn

    name.replace(new RegExp("_", "g"), " ")
    console.log "In hsn find: " + name
    # json_data = {query: "MATCH n:hsn<-[:IS_COMPONENT_OF]-m:ci WHERE n.name! = {hsnName} RETURN m", params : { hsnName: "vio prd hpg"}}
    json_data = {query: "MATCH n:hsn<-[:IS_COMPONENT_OF]-m:ci WHERE n.name! = 'vio prd hpg' RETURN m"}
    console.log json_data
    json_url = "http://localhost:7474/db/data/cypher"

    return $.post(json_url, json_data)
      .then (response) ->
        console.log response["data"][0]["data"]
        response   
