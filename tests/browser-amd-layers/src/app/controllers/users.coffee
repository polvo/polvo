AppController = require 'app/app_controller'
UserView = require 'app/views/user_view'

# testing dependencies
describe 'Users (app/controllers/users.coffee)', ->
  it 'All depdendencies should have been loaded', ->
    should.exist AppController
    should.exist UserView

module.exports = class Users extends AppController
  render:( users )->

      describe 'Users.render (app/controllers/users.coffee)', ->
        it 'A UserView must to be instantiated for each user', ->
          for user, index in users
            user = new UserView user
            user.should.exist
            user.data.should.exist 
            (expect user).to.be.an.instanceof UserView