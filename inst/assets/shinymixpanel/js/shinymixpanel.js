let shinymixpanel = {
  // User-defined parameters coming from R
  token : "",
  options : {},
  userid : "",
  defaultProps : {},
  defaultPropsJS : {},
  testToken : "",
  testDomains : {},
  force : false,

  finalToken : "",
  reachable : true,
  waitingConfirmReachable : true,
  eventsQueue : [],

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

      mixpanel.init(shinymixpanel.finalToken, shinymixpanel.options);

      shinymixpanel.identifyUser();

      shinymixpanel.checkReachable();
    } catch(e) {
      shinymixpanel.setUnreachable();
    }
  },

  checkReachable : function() {
    if (!shinymixpanel.force) return;

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
    if (!shinymixpanel.force) return;

    shinymixpanel.waitingConfirmReachable = false;
    shinymixpanel.reachable = false;

    let props = {};
    props['$screen_height'] = screen.height;
    props['$screen_width'] = screen.width;
    props['$os'] = shinymixpanel.getOS().name;
    props['$browser'] = shinymixpanel.getBrowser().name;
    props['$browser_version'] = shinymixpanel.getBrowser().version;
    shinymixpanel.copyProps(shinymixpanel.defaultPropsJS, props, true);

    let data = {
      'token' : shinymixpanel.finalToken,
      'events' : shinymixpanel.eventsQueue,
      'js_props' : props
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
  let props = {};
  shinymixpanel.copyProps(shinymixpanel.defaultProps, props, false);
  shinymixpanel.copyProps(shinymixpanel.defaultPropsJS, props, true);
  shinymixpanel.copyProps(params.properties, props, false);

  // If the client is unreachable but this method still got called, it means
  // that an event was getting tracked before the server had a chance to learn
  // that it's unreachable. So send the event back to the server
  if (!shinymixpanel.reachable) {
    Shiny.setInputValue(
      "shinymixpanel__track:shinymixpanel",
      { event : params.event, properties : props },
      {event: 'priority'}
    );
    return;
  }

  mixpanel.track(params.event, props);

  // While we're still waiting to confirm if mixpanel is reachable by the client,
  // keep a record of all the events so that we can send them through the server
  // later if needed
  if (shinymixpanel.waitingConfirmReachable && shinymixpanel.force) {
    shinymixpanel.eventsQueue.push({ event : params.event, properties : props });
  }
});

Shiny.addCustomMessageHandler('shinymixpanel.setUserID', function(params) {
  if (!shinymixpanel.reachable) return;

  shinymixpanel.userid = params.userid;
  shinymixpanel.identifyUser();

  // When setting the user ID, it's possible that previously mixpanel
  // was reachable (no adblocker) but the new user opted out of mixpanel,
  // so need to check again
  shinymixpanel.waitingConfirmReachable = true;
  shinymixpanel.checkReachable();
});

Shiny.addCustomMessageHandler('shinymixpanel.setDefaultProps', function(params) {
  if (!shinymixpanel.reachable) return;
  shinymixpanel.defaultProps = params.props;
});
