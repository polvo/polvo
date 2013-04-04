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
