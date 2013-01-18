#<< toaster/utils/object_util

{ObjectUtil} = toaster.utils

class ArrayUtil

  @find:( src, search )->
    for v, i in src
      unless (search instanceof Object)
        return item: v, index:i if v == search
      else
        return {item: v, index:i } if ObjectUtil.find(v, search)?
    return null

  @delete:( src, search )->
    item = ArrayUtil.find src, search
    src.splice item.index, 1 if item?

  @has:(source, search)->
    return (ArrayUtil.find source, search )?

  @replace_into:( src, index, items )->
    items = [].concat items
    src.splice index, 1
    while items.length
      src.splice index++, 0, items.shift()
    src