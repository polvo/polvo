#<< toaster/utils/object_util

{ObjectUtil} = toaster.utils

class ArrayUtil

  ###
  @param [] src
  @param [] search
  ###
  @find:( src, search )->
    for v, i in src
      unless (search instanceof Object)
        return item: v, index:i if v == search
      else
        return {item: v, index:i } if ObjectUtil.find(v, search)?
    return null

  ###
  @param [] src
  @param [] search
  ###
  @delete:( src, search )->
    item = ArrayUtil.find src, search
    src.splice item.index, 1 if item?


  # @diff:(a = [], b = [], by_property)->
  #   diff = []
    
  #   for item in a
  #     search = if by_property? then item[by_property] else item
  #     if !ArrayUtil.has b, search, by_property
  #       diff.push {item:item, action:"deleted"}
    
  #   for item in b
  #     search = if by_property? then item[by_property] else item
  #     if !ArrayUtil.has a, search, by_property
  #       diff.push {item:item, action:"created"}
    
  #   diff



  @has:(source, search)->
    return (ArrayUtil.find source, search )?



  @replace_into:( src, index, items )->
    items = [].concat items
    src.splice index, 1
    while items.length
      src.splice index++, 0, items.shift()
    src