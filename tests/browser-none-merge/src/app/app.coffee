require 'jquery'

Users = require 'app/controllers/users'
User = require 'app/models/user'

# testing dependencies
describe 'App (app/app.coffee)', ->
  it 'All depdendencies should have been loaded', ->
    should.exist $
    should.exist Users
    should.exist User


# defining app
class App
  constructor:->

    new User 'anderson', 'arboleya'
    new User 'henrique', 'matias'

    user_list = User.all()

    users = new Users
    users.render user_list

new App()

($ document).ready ->
  if window.mochaPhantomJS
      mochaPhantomJS.run()
  else
      mocha.run()