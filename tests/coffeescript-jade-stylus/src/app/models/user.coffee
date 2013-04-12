AppModel = require 'app/models/app_model'


# testing dependencies
describe 'User (app/models/user.coffee)', ->
  it 'All depdendencies should have been loaded', ->
    should.exist AppModel

module.exports = class User extends AppModel
  _all = []

  constructor:( @first_name, @last_name )->
  	_all.push @

  @all = -> _all