define('app/app_model', [], function() {
  var AppModel;

  return AppModel = (function() {
    function AppModel() {}

    return AppModel;

  })();
});
define('app/app_view', [], function() {
  var AppView;

  return AppView = (function() {
    function AppView() {}

    return AppView;

  })();
});
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define('app/models/user', ['app/app_model'], function(AppModel) {
  var User;

  describe('User (app/models/user.coffee)', function() {
    return it('All depdendencies should have been loaded', function() {
      return should.exist(AppModel);
    });
  });
  return User = (function(_super) {
    var _all;

    __extends(User, _super);

    _all = [];

    function User(first_name, last_name) {
      this.first_name = first_name;
      this.last_name = last_name;
      _all.push(this);
    }

    User.all = function() {
      return _all;
    };

    return User;

  })(AppModel);
});
define('app/app_controller', [], function() {
  var AppController;

  return AppController = (function() {
    function AppController() {}

    return AppController;

  })();
});
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define('app/views/user_view', ['app/app_view'], function(AppView) {
  var UserView;

  describe('UserView (app/views/user_view.coffee)', function() {
    return it('All depdendencies should have been loaded', function() {
      return should.exist(AppView);
    });
  });
  return UserView = (function(_super) {
    __extends(UserView, _super);

    function UserView(data) {
      this.data = data;
      this.dom = "<h1>New User</h1>\n<ul id=\"" + this.data.first_name + "\">\n  <li>first name: " + this.data.first_name + " </li>\n  <li>last name: " + this.data.last_name + " </li>\n</ul>";
    }

    return UserView;

  })(AppView);
});
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define('app/controllers/users', ['app/app_controller', 'app/views/user_view'], function(AppController, UserView) {
  var Users, _ref;

  describe('Users (app/controllers/users.coffee)', function() {
    return it('All depdendencies should have been loaded', function() {
      should.exist(AppController);
      return should.exist(UserView);
    });
  });
  return Users = (function(_super) {
    __extends(Users, _super);

    function Users() {
      _ref = Users.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Users.prototype.render = function(users) {
      return describe('Users.render (app/controllers/users.coffee)', function() {
        return it('A UserView must to be instantiated for each user', function() {
          var index, user, _i, _len, _results;

          _results = [];
          for (index = _i = 0, _len = users.length; _i < _len; index = ++_i) {
            user = users[index];
            user = new UserView(user);
            user.should.exist;
            user.data.should.exist;
            _results.push((expect(user)).to.be.an["instanceof"](UserView));
          }
          return _results;
        });
      });
    };

    return Users;

  })(AppController);
});
define('app/app', ['app/controllers/users', 'app/models/user', 'jquery'], function(Users, User) {
  var App;

  describe('App (app/app.coffee)', function() {
    return it('All depdendencies should have been loaded', function() {
      should.exist($);
      should.exist(Users);
      return should.exist(User);
    });
  });
  return App = (function() {
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
});
var should;

should = null;

define('boot', ['chai', 'mocha'], function(chai) {
  should = chai.should();
  window.expect = chai.expect;
  mocha.setup('bdd');
  describe('Boot (boot.coffee)', function() {
    return it('Tests suites must to be loaded and available', function() {
      should.exist(mocha);
      return should.exist(chai);
    });
  });
  return require(['app/app'], function(App) {
    new App();
    return ($(document)).ready(function() {
      if (window.mochaPhantomJS) {
        return mochaPhantomJS.run();
      } else {
        return mocha.run();
      }
    });
  });
});
