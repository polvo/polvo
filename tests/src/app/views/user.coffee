AppView = require 'app/views/app_view'

Template = require 'templates/user'
Styles = require 'styles/user'

# testing dependencies
describe 'UserView (app/views/user.coffee)', ->
  it 'All depdendencies should have been loaded', ->
    should.exist AppView
    should.exist Template
    should.exist Styles

module.exports = class UserView extends AppView

  constructor:( @data )->
    @dom = """
      <h1>New User</h1>
      <ul id="#{@data.first_name}">
        <li>first name: #{@data.first_name} </li>
        <li>last name: #{@data.last_name} </li>
      </ul>"""