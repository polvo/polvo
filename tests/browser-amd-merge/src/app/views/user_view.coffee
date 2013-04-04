AppView = require 'app/app_view'

# testing dependencies
describe 'UserView (app/views/user_view.coffee)', ->
  it 'All depdendencies should have been loaded', ->
    should.exist AppView

class UserView extends AppView

  constructor:( @data )->
    @dom = """
      <h1>New User</h1>
      <ul id="#{@data.first_name}">
        <li>first name: #{@data.first_name} </li>
        <li>last name: #{@data.last_name} </li>
      </ul>"""