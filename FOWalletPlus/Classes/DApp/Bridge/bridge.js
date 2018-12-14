"use strict";

(function () {
  var promiseChain = Promise.resolve();
  var promises = {};
  var callbacks = {};

  var init = function init() {
    var guid = function guid() {
      function s4() {
        return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
      }
      return s4() + s4() + "-" + s4() + "-" + s4() + "-" + s4() + "-" + s4() + s4() + s4();
    };
    window.bridge = {
      callAPI: function callAPI(api, data, callback) {
        callback = callback || function () {};
        var msg = {
          api: api,
          data: data,
          msgId: guid()
        };
        var msg_ = JSON.stringify(msg);
        promiseChain = promiseChain.then(function () {
          return new Promise(function (resolve, reject) {
            promises[msg.msgId] = { resolve: resolve, reject: reject };
            callbacks[msg.msgId] = {
              callback: callback
            };
            window.webkit.messageHandlers.FOWallet.postMessage(msg_);
          });
        }).catch(function (e) {
          console.error("rnBridge send failed " + e.message);
        });
      }
    };

    window.document.addEventListener("message", function (e) {
      var message = undefined;
      try {
        message = JSON.parse(e.data);
      } catch (err) {
        console.error("failed to parse message from react-native " + err);
        return;
      }
      if (promises[message.msgId]) {
        promises[message.msgId].resolve();
        delete promises[message.msgId];
      }

      if (message.args && callbacks[message.msgId]) {
        callbacks[message.msgId].callback.apply(null, message.args);
        delete callbacks[message.msgId];
      }
    });
  };

  init();
})();
