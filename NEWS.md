# shinymixpanel 0.2.0 (2023-02-24)

- Allow sending Mixpanel event tracking from non-shiny R scripts
- Add `track_client` and `track_server` parameters to `mp_init()`. When Mixpanel tracking is disabled in a user's browser (for example because of an Ad Blocker), if `track_server = TRUE` then {shinymixpanel} will automatically send event data using Mixpanel's server API calls instead. Using the server calls is inferior because some data about the user is lost such as geolocation.
- Add full documentation

# shinymixpanel 0.1.0 (2022-10-13)

- Initial (non-CRAN) release
