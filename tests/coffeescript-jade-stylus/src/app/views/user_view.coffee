AppView = require 'app/app_view'

template = require 'app/views/test'
styles = require 'app/views/styles-test'

# testing dependencies
describe 'UserView (app/views/user_view.coffee)', ->
  it 'All depdendencies should have been loaded', ->
    should.exist AppView
    should.exist template
    should.exist styles

module.exports = class UserView extends AppView

  constructor:( @data )->
    @dom = """
      <h1>New User</h1>
      <ul id="#{@data.first_name}">
        <li>first name: #{@data.first_name} </li>
        <li>last name: #{@data.last_name} </li>
      </ul>"""