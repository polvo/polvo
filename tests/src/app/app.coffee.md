Some literate comments here just in order to test it.

  require 'jquery'

  Users = require 'app/controllers/users'
  User = require 'app/models/user'

  # testing dependencies
  describe 'App (app/app.coffee)', ->
    it 'All depdendencies should have been loaded', ->
      should.exist $
      should.exist Users
      should.exist User

A little more here.

  # defining app
  module.exports = class App
    constructor:->

      new User 'anderson', 'arboleya'
      new User 'henrique', 'matias'

      user_list = User.all()

      users = new Users
      users.render user_list

And a final note here.