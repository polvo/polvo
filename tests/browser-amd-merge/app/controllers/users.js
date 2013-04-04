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
