/*
    manifest
        { Client: Client
        , mountPath: String
        , buildNumber: Int
        }

*/

var Flags = require("./Js/Flags");

Desktop = function(manifest) {
    var Client = manifest.Client;
    var track = manifest.track;
    var app;

    function toElm(type, payload) {
        app.ports.fromJs.send({
            type: type,
            payload: payload
        });
    };

    function handleLoginSuccess(user) {
        user.getUserAttributes(function(err, attributes) {
            if (err) {
                toElm("login failed", String(err));
            } else {
                toElm("login succeeded", toUser(attributes));
            }
        });
    }

    var handleLogin = {
        onSuccess: handleLoginSuccess,
        onFailure: function(err) {
            toElm("login failed", String(err));
        }
    };

    var handleLogout = {
        onSuccess: function() {
            toElm("logout succeeded", null);
        },
        onFailure: function(err) {
            toElm("logout failed", err);
        }
    };

    function jsMsgHandler(msg) {
        switch (msg.type) {
            case "log in" :
                Client.login(msg.payload, handleLogin);
                break;

            case "verify email" :
                Client.verify(msg.payload, {
                    onFailure: function(err) {
                        toElm("verification failed", err);
                    },
                    onSuccess: function(result) {
                        toElm('verification succeeded', result);
                    }
                });
                break;

            case "register" :
                Client.register(msg.payload, {
                    onFailure: function(err) { 
                        toElm("registration failed", err)
                    },
                    onSuccess: function(result) {
                        toElm("registration succeeded", result.user.username);
                    }
                });
                break;

            case "log out" :
                Client.logout(handleLogout);
                break;

            case "get drawings":
                Client.getDrawings({
                    onSuccess: function(result) {
                        console.log("Result!", result);
                    },
                    onFailure: function(err) {
                        console.log("Error!", err);
                    }
                })
                break;

            default:
                console.log("Unknown js msg type", msg.type);
        }
    }

    function toUser(attributes) {
        var payload = {};

        for (i = 0; i < attributes.length; i++) {
            payload[ attributes[i].getName() ] = attributes[i].getValue();
        }

        return payload;
    }

    function init(mixins) {
        app = Elm.Desktop.fullscreen(Flags.make(mixins));
        app.ports.toJs.subscribe(jsMsgHandler);
    }

    Client.getSession({
        onSuccess: function(attributes) {
            init({
                user: toUser(attributes),
                manifest: manifest
            });
        },
        onFailure: function(err) {
            switch (String(err)) {
                case "no session" :
                    init({ 
                        user: null,
                        manifest: manifest
                    });
                    break;

                case "NetworkingError: Network Failure":
                    init({ 
                        user: "offline",
                        manifest: manifest
                    });
                    break;

                case "UserNotFoundException: User does not exist.":
                    init({ 
                        user: null,
                        manifest: manifest
                    });
                    break;

                default : 
                    console.log("Unknown get session error", err);
            }
        }
    });
};

