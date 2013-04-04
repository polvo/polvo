define('app/app', ['app/controllers/users', 'app/models/user', 'jquery'], function(Users, User) {
  var App;

  describe('App (app/app.coffee)', function() {
    return it('All depdendencies should have been loaded', function() {
      should.exist($);
      should.exist(Users);
      return should.exist(User);
    });
  });
  App = (function() {
    function App() {
      var user_list, users;

      new User('anderson', 'arboleya');
      new User('henrique', 'matias');
      user_list = User.all();
      users = new Users;
      users.render(user_list);
    }

    return App;

  })();
  new App();
  return ($(document)).ready(function() {
    if (window.mochaPhantomJS) {
      return mochaPhantomJS.run();
    } else {
      return mocha.run();
    }
  });
});
