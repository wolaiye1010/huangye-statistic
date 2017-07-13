var Util = {};
Util.number = {};
Util.lang = {};
Util.string = {};
Util.date = {};
Util.cookie = {};
Util.param = {};
Util.input = {};

// 获取appId
Util.param.getId = function (name) {
    var reg = new RegExp('(^|&)' + name + '=([^&]*)(&|$)', 'i');
    var r = window.location.search.substr(1).match(reg);
    if (r != null) {
        return unescape(r[2]);
    }
    return null;
};