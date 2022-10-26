let shinymixpanel = {
  // User-defined parameters coming from R
  token : "",
  options : {},
  userid : "",
  defaultProps : {},
  defaultPropsJS : {},
  testToken : "",
  testDomains : {},
  trackServer : false,

  finalToken : "",
  reachable : true,
  waitingConfirmReachable : true,
  eventsQueue : [],
  senderQueue : new ShinySenderQueue(),

  // Copied from github.com/daattali/shinybrowser@1.0.0
  getBrowser : function() {
    var browser = 'UNKNOWN';
    var version = 'UNKNOWN';
    var ua = navigator.userAgent;

    try {
    	// Opera 15+
    	if (ua.indexOf('OPR/') >= 0) {
    	  browser = 'Opera';
    	  version = ua.match(/OPR\/(\d+)/i)[1];
    	}

    	// Firefox 1+
    	else if (typeof InstallTrigger !== 'undefined') {
    		browser = 'Firefox';
    		version = ua.match(/(firefox(?=\/))\/?\s*(\d+)/i)[2];
    	}

    	// Safari 3+
    	else if (/constructor/i.test(window.HTMLElement) ||
    	         (typeof window.safari !== 'undefined' &&
    	           typeof window.safari.pushNotification !== 'undefined')) {
    		browser = 'Safari';
    		version = ua.match(/version\/(\d+)/i)[1];
    	}

    	// Internet Explorer 6-11
    	else if (/* @cc_on!@*/false || document.documentMode) {
    		browser = 'Internet Explorer';
    		var msie = ua.indexOf('MSIE ');
        if (msie > 0) { // IE 10-
          version = parseInt(ua.substring(msie + 5, ua.indexOf('.', msie)), 10);
        } else {
          if (ua.match(/Trident.*rv\:11\./)) { // IE 11
            version = '11';
          }
        }
    	}

    	// Edge 20+
    	else if (!(document.documentMode) && window.StyleMedia) {
    		browser = 'Edge';
    		var edge = ua.indexOf('Edge/');
    		if (edge > 0) {
    		  version = parseInt(ua.substring(edge + 5, ua.indexOf('.', edge)), 10);
    		}
    	}

    	// Edge based on Chromium
    	else if (window.chrome && ua.indexOf("Edg") != -1) {
    	  browser = 'Edge';
    	  version = ua.match(/Chrom(e|ium)\/([0-9]+)\./i)[2];
    	}

    	// Chrome
    	else if (window.chrome) {
    		browser = 'Chrome';
    		version = ua.match(/Chrom(e|ium)\/([0-9]+)\./i)[2];
    	}

    	// Chrome on iOS
    	else if (ua.indexOf('CriOS/') >= 0) {
    		browser = 'Chrome';
    		version = ua.match(/CriOS\/([0-9]+)\./i)[1];
    	}
    } catch(err) {}

    return { name : browser, version : version };
  },

  // Copied from github.com/daattali/shinybrowser@1.0.0
  getOS : function() {
    var os = 'UNKNOWN';
    var version = 'UNKNOWN';
    var ua = navigator.userAgent;

    try {
    	if (/Mobi/.test(navigator.userAgent)) {
    		if (/Windows/.test(ua)) {
    			os = 'Windows Phone';
    			if (/Phone 8.0/.test(ua)) {
    				version = 8;
    			} else if (/Phone 10.0/.test(ua)) {
    				version = 10;
    			}
    		} else if (/android/i.test(ua)) {
          os = 'Android';
    			version = parseInt(ua.match(/android\s([0-9\.]*)/i)[1]);
    		} else if (/iphone;/i.test(navigator.userAgent)) {
    			os = 'iOS';
          version = parseInt((navigator.appVersion).match(/OS (\d+)_(\d+)_?(\d+)?/)[1]);
    		} else if (/ipad;/i.test(navigator.userAgent)) {
    			os = 'iOS';
    			version = parseInt((navigator.appVersion).match(/OS (\d+)_(\d+)_?(\d+)?/)[1]);
    		} else if (/BBd*/.test(navigator.userAgent)) {
    			os = 'BlackBerry';
    		}
    	} else {
    		if (/Windows/.test(navigator.userAgent)) {
    			os = 'Windows';
    			if (/NT 5.1;/.test(navigator.userAgent)) {
    				version = 'XP';
    			} else if (/NT 6.0;/.test(navigator.userAgent)) {
    				version = 'Vista';
    			} else if (/NT 6.1;/.test(navigator.userAgent)) {
    				version = '7';
    			} else if (/NT 6.2;/.test(navigator.userAgent)) {
    				version = '8';
    			} else if (/NT 10.0;/.test(navigator.userAgent)) {
    				version = '10';
    			}
    		} else if (/Mac/.test(navigator.userAgent)) {
    			os = 'Mac';
    			if (/OS X/.test(navigator.userAgent)) {
    				version = 'OS X';
    			}
    		} else if (/Linux|X11/.test(navigator.userAgent)) {
    			os = 'Linux';
    		}
    	}
    } catch(err) {}

  	return { name : os, version : version };
  },

  copyProps : function(from, to, js = false) {
    Object.keys(from).forEach(key => {
      if (js) {
        to[key] = eval(from[key]);
      } else {
        to[key] = from[key];
      }
    });
  },

  load : function() {
    try {
      if (shinymixpanel.token === "") {
        console.log("shinymixpanel: no token found");
        return;
      }

      shinymixpanel.finalToken = shinymixpanel.token;

      if (shinymixpanel.testToken !== "" && shinymixpanel.testDomains !== {}) {
        if (shinymixpanel.testDomains.find(url => location.hostname.endsWith(url))) {
          console.log("shinymixpanel: using test token");
          shinymixpanel.finalToken = shinymixpanel.testToken;
        }
      }

      (function(f,b){if(!b.__SV){var e,g,i,h;window.mixpanel=b;b._i=[];b.init=function(e,f,c){function g(a,d){var b=d.split(".");2==b.length&&(a=a[b[0]],d=b[1]);a[d]=function(){a.push([d].concat(Array.prototype.slice.call(arguments,0)))}}var a=b;"undefined"!==typeof c?a=b[c]=[]:c="mixpanel";a.people=a.people||[];a.toString=function(a){var d="mixpanel";"mixpanel"!==c&&(d+="."+c);a||(d+=" (stub)");return d};a.people.toString=function(){return a.toString(1)+".people (stub)"};i="disable time_event track track_pageview track_links track_forms track_with_groups add_group set_group remove_group register register_once alias unregister identify name_tag set_config reset opt_in_tracking opt_out_tracking has_opted_in_tracking has_opted_out_tracking clear_opt_in_out_tracking start_batch_senders people.set people.set_once people.unset people.increment people.append people.union people.track_charge people.clear_charges people.delete_user people.remove".split(" ");
        for(h=0;h<i.length;h++)g(a,i[h]);var j="set set_once union unset remove delete".split(" ");a.get_group=function(){function b(c){d[c]=function(){call2_args=arguments;call2=[c].concat(Array.prototype.slice.call(call2_args,0));a.push([e,call2])}}for(var d={},e=["get_group"].concat(Array.prototype.slice.call(arguments,0)),c=0;c<j.length;c++)b(j[c]);return d};b._i.push([e,f,c])};b.__SV=1.2;e=f.createElement("script");e.type="text/javascript";e.async=!0;e.src="undefined"!==typeof MIXPANEL_CUSTOM_LIB_URL?
          MIXPANEL_CUSTOM_LIB_URL:"file:"===f.location.protocol&&"//cdn.mxpnl.com/libs/mixpanel-2-latest.min.js".match(/^\/\//)?"https://cdn.mxpnl.com/libs/mixpanel-2-latest.min.js":"//cdn.mxpnl.com/libs/mixpanel-2-latest.min.js";g=f.getElementsByTagName("script")[0];g.parentNode.insertBefore(e,g)}})(document,window.mixpanel||[]);

      shinymixpanel.options.ignore_dnt = true;

      mixpanel.init(shinymixpanel.finalToken, shinymixpanel.options);
      shinymixpanel.identifyUser();

      shinymixpanel.checkReachable();
    } catch(e) {
      shinymixpanel.setUnreachable();
    }
  },

  checkReachable : function() {
    if (!shinymixpanel.trackServer) return;

    if (typeof mixpanel === 'undefined') {
      shinymixpanel.setUnreachable();
    } else {
      (async () => {
        try {
          const data = await fetch("https://api-js.mixpanel.com/track/", {method: "POST"})
          if (data.status !== 200) {
            shinymixpanel.setUnreachable();
          } else {
            setTimeout(() => {
              if (typeof mixpanel.has_opted_out_tracking() === 'undefined' || mixpanel.has_opted_out_tracking()){
                shinymixpanel.setUnreachable();
              } else {
                shinymixpanel.waitingConfirmReachable = false;
                shinymixpanel.eventsQueue = [];
              }
            }, 3000)
          }
        } catch (e) {
          shinymixpanel.setUnreachable();
        }
      })()
    }
  },

  setUnreachable : function() {
    if (!shinymixpanel.trackServer) return;

    shinymixpanel.waitingConfirmReachable = false;
    shinymixpanel.reachable = false;

    let client_props = {
      '$screen_height' : screen.height,
      '$screen_width' : screen.width,
      '$os' : shinymixpanel.getOS().name,
      '$browser' : shinymixpanel.getBrowser().name,
      '$browser_version' : shinymixpanel.getBrowser().version,
      '$current_url' : location.href
    };

    if (typeof shinymixpanel.options !== 'undefined' &&
        typeof shinymixpanel.options.property_blacklist !== 'undefined') {
      Object.keys(client_props).forEach(key => {
        if (shinymixpanel.options.property_blacklist.includes(key)) {
          delete client_props[key];
        }
      });
    }

    shinymixpanel.copyProps(shinymixpanel.defaultPropsJS, client_props, true);

    let data = {
      'token' : shinymixpanel.finalToken,
      'events' : shinymixpanel.eventsQueue,
      'userid' : shinymixpanel.userid,
      'client_props' : client_props,
      'props' : shinymixpanel.defaultProps
    };

    Shiny.setInputValue("shinymixpanel__unreachable:shinymixpanel", data, {event: 'priority'});
    shinymixpanel.eventsQueue = [];
  },

  identifyUser : function() {
    if (shinymixpanel.userid !== "") {
      mixpanel.identify(shinymixpanel.userid);
    }
  },

  init : function() {
    if (typeof Shiny === "undefined" || typeof Shiny.setInputValue === "undefined") {
      $(document).on('shiny:connected', function(event) {
        shinymixpanel.load();
      });
    } else {
      shinymixpanel.load();
    }
  }
};

$(function() { shinymixpanel.init(); });


Shiny.addCustomMessageHandler('shinymixpanel.track', function(params) {
  // Create two versions of the properties
  // Full version which includes JS properties is for sending to Mixpanel immediately
  // Partial version without JS properties is for potentially sendin to the server
  // (since the server already has a copy of the JS properties + extra client-side properties)
  let props_no_js = {};
  let props_full = {};
  shinymixpanel.copyProps(shinymixpanel.defaultProps, props_no_js, false);
  shinymixpanel.copyProps(params.properties, props_no_js, false);
  shinymixpanel.copyProps(shinymixpanel.defaultProps, props_full, false);
  shinymixpanel.copyProps(shinymixpanel.defaultPropsJS, props_full, true);
  shinymixpanel.copyProps(params.properties, props_full, false);

  let serverEvent = {
    event : params.event,
    properties : props_no_js,
    userid: shinymixpanel.userid
  };

  // If the client is unreachable but this method still got called, it means
  // that an event was getting tracked before the server had a chance to learn
  // that it's unreachable. So send the event back to the server.
  if (!shinymixpanel.reachable) {
    shinymixpanel.senderQueue.send("shinymixpanel__track:shinymixpanel", serverEvent);
    return;
  }

  mixpanel.track(params.event, props_full);

  // While we're still waiting to confirm if mixpanel is reachable by the client,
  // keep a record of all the events so that we can send them through the server
  // later if needed
  if (shinymixpanel.waitingConfirmReachable && shinymixpanel.trackServer) {
    shinymixpanel.eventsQueue.push(serverEvent);
  }
});

Shiny.addCustomMessageHandler('shinymixpanel.setUserID', function(params) {
  shinymixpanel.userid = params.userid;
  shinymixpanel.identifyUser();
});

Shiny.addCustomMessageHandler('shinymixpanel.setDefaultProps', function(params) {
  shinymixpanel.defaultProps = params.props;
});


// ShinySenderQueue code taken from Joe Cheng
// https://github.com/rstudio/shiny/issues/1476
function ShinySenderQueue() {
  this.readyToSend = true;
  this.queue = [];
  this.timer = null;
}
ShinySenderQueue.prototype.send = function(name, value) {
  var self = this;
  function go() {
    self.timer = null;
    if (self.queue.length) {
      var msg = self.queue.shift();
      if (typeof Shiny === 'object' && typeof Shiny.compareVersion === 'function' &&
          Shiny.compareVersion(Shiny.version, '>=', '1.1.0')) {
        Shiny.setInputValue(msg.name, msg.value, {priority: "event"});
      } else {
        Shiny.onInputChange(msg.name, msg.value);
      }
      self.timer = setTimeout(go, 0);
    } else {
      self.readyToSend = true;
    }
  }
  if (this.readyToSend) {
    this.readyToSend = false;
    if (typeof Shiny === 'object' && typeof Shiny.compareVersion === 'function' &&
        Shiny.compareVersion(Shiny.version, '>=', '1.1.0')) {
      Shiny.setInputValue(name, value, {priority: "event"});
    } else {
      Shiny.onInputChange(name, value);
    }
    this.timer = setTimeout(go, 0);
  } else {
    this.queue.push({name: name, value: value});
    if (!this.timer) {
      this.timer = setTimeout(go, 0);
    }
  }
};
