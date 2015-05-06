define(['settings'],
function (Settings) {
  return new Settings({

    datasources: {
      graphite: {
        type: 'graphite',
        url: "/graphite",
      }
      /*,
      elasticsearch: {
        type: 'elasticsearch',
        url: "/elasticsearch",
        index: 'grafana-dash',
        grafanaDB: true,
      }
      */
    },

    // specify the limit for dashboard search results
    search: {
      max_results: 20
    },

    // default start dashboard
    default_route: '/dashboard/file/default.json',

    // set to false to disable unsaved changes warning
    unsaved_changes_warning: true,

    // set the default timespan for the playlist feature
    // Example: "1m", "1h"
    playlist_timespan: "1m",

    // If you want to specify password before saving, please specify it bellow
    // The purpose of this password is not security, but to stop some users from accidentally changing dashboards
    admin: {
      password: 'admin-secret'
    },

    // Add your own custom pannels
    plugins: {
      panels: []
    }

  });
});

