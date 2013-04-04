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
