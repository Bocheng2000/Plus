"use strict";
window.fowallet.getInfo = function(callback) {
    window.bridge.callAPI("getInfo", undefined, callback);
};
window.fowallet.getAccount = function(callback) {
    window.bridge.callAPI("getAccount", undefined, callback);
};
window.fowallet.getCurrencyBalance = function(options, callback) {
    window.bridge.callAPI("getCurrencyBalance", options, callback);
};
window.fowallet.getLockBalance = function(options, callback) {
    window.bridge.callAPI("getLockBalance", options, callback)
};
window.fowallet.payRequest = function(options, callback) {
    window.bridge.callAPI("payRequest", options, callback)
};
function _eos(network, _fibos) {
    var _options = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : {};
    var httpEndpoint = network.protocol + "://" + network.host + ":" + network.port;
    return _fibos({
        httpEndpoint: httpEndpoint,
        chainId: _options.chainId,
        signProvider: function signProvider(_ref) {
            var buf = _ref.buf,
                sign = _ref.sign,
                transaction = _ref.transaction;
            return new Promise(function(resolve, reject) {
                window.bridge.callAPI("signProvider", _ref, function(err, result) {
                    if (err) {
                        reject(err);
                    } else {
                        resolve(result);
                    }
                });
            });
        }
    });
}
window.ironman = {}
window.ironman.requireVersion = function (version) {};
window.ironman.getIdentity = function (options) {
    return new Promise(function(resolve, reject) {
        window.bridge.callAPI("getIdentity", options, function(err, data) {
            if (err) {
                reject(err);
            } else {
                window.ironman.identity = {
                    accounts: data.accounts,
                };
                resolve(data);
            }
        });
    });
};
window.ironman.suggestNetwork = function() {};
window.ironman.forgetIdentity = function () {
    return new Promise(function (resolve, reject) {
        if (window.ironman && window.ironman.identity) {
            resolve(window.ironman.identity);
            window.ironman.identity = undefined;
        } else {
            reject("No valid identity found");
        }
    });
};
window.ironman.eos = _eos;
window.ironman.fibos = _eos;
var event = new Event("sdkReady");
window.dispatchEvent(event);
var evt = new Event("ironmanLoaded");
window.document.dispatchEvent(evt);
