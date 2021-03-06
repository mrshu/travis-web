Travis.LimitedArray = Em.ArrayProxy.extend
  limit: 10
  isLoadedBinding: 'content.isLoaded'
  insertAtTheBeginning: true

  init: ->
    @_super.apply this, arguments

  arrangedContent: (->
    content = @get('content')
    if @get('disable')
      content
    else if content
      content.slice(0, @get('limit'))
  ).property('content', 'limit', 'disable')

  totalLength: (->
    @get('content.length')
  ).property('content.length')

  leftLength: (->
    totalLength = @get('totalLength')
    limit       = @get('limit')
    if totalLength > limit
      totalLength - limit
    else
      0
  ).property('totalLength', 'limit')

  isMore: (->
    @get('leftLength') > 0
  ).property('leftLength')

  showAll: ->
    @set 'limit', 1000000000
    @set 'disable', true

  contentArrayDidChange: (array, index, removedCount, addedCount) ->
    @_super.apply this, arguments

    return if @get('disable')

    limit  = @get 'limit'
    arrangedContent = @get('arrangedContent')
    length = arrangedContent.get 'length'

    if addedCount > 0
      addedObjects = array.slice(index, index + addedCount)
      for object in addedObjects
        if @get('insertAtTheBeginning')
          arrangedContent.unshiftObject(object)
        else
          arrangedContent.pushObject(object)

    if removedCount
      removedObjects = array.slice(index, index + removedCount);
      arrangedContent.removeObjects(removedObjects)

    length = arrangedContent.get 'length'
    content = @get('content')

    if length > limit
      arrangedContent.replace(limit, length - limit)
    else if length < limit && content.get('length') > length
      count = limit - length
      while count > 0
        if next = content.find( (object) -> !arrangedContent.contains(object) )
          if @get('insertAtTheBeginning')
            arrangedContent.unshiftObject(object)
          else
            arrangedContent.pushObject(object)
        count -= 1
