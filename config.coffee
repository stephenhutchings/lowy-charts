fs   = require("fs")
data = require("./utils/data")
git  = require("git-rev-sync")
glob = require("glob")
hash = git.short()


glob "app/static/**/*.pug", (err, list) ->
  console.log list.map((e) ->
    e
      .replace("app/static/", "http://localhost:4000/")
      .replace("index.pug", "")
      .replace(".pug", ".html")

  ).filter((e) -> not e.match(/partials|survey-results\/q/)
  ).join("\n")


exports.config =
  paths:
    public: "build"

  server:
    hostname: "0.0.0.0"

  conventions:
    assets: /app\/(assets|static)\//
    ignored: [
      /[\\/]_/
      "node_modules"
      /\/partials\//
      /^app\/static(\/|\\)(.+)\.yaml$/
      /\.(tmp\$\$)$/
    ]

  plugins:
    autoprefixer:
      browsers: ["> 1%"]

    pug:
      staticBasedir: "app/static/"
      locals:
        _:        require("lodash")
        moment:   require("moment")
        typogr:   require("typogr")
        written:  require("written")
        marked:   require("marked")
        package:  require("./package.json")
        data:     data
        version:  hash
      filters:
        sass: (data) ->
          require("node-sass").renderSync({
            data
            indentedSyntax: true
          }).css.toString()

        coffee: (data) ->
          require("coffeescript").compile(data)

    sass:
      mode: "native"

    coffeelint:
      pattern: /^app\/.*\.coffee$/

      options:
        no_empty_param_list:
          level: "error"

        prefer_english_operator:
          value: true
          level: "warn"

        indentation:
          value: 2
          level: "warn"

        max_line_length:
          level: "warn"

    postcss:
      processors: [
        require("autoprefixer")(["> 1%"])
        require("csswring")({ preserveHacks: true })
      ]

  overrides:
    production:
      plugins:
        pug:
          staticPretty: false
          filters:
            sass: (data) ->
              require("node-sass").renderSync({
                data
                indentedSyntax: true
                outputStyle: "compressed"
              }).css.toString()

  files:
    javascripts:
      joinTo:
        "js/app.#{hash}.js": /^app\//
        "js/vendor.#{hash}.js": /^(vendor|bower_components)/

      order:
        before: [
          "bower_components/underscore/underscore.js"
          "bower_components/jquery/dist/jquery.js"
          "bower_components/moment/moment.js"
          "bower_components/backbone/backbone.js"
        ]

    stylesheets:
      joinTo:
        "css/app.#{hash}.css": "app/sass/app.sass"

    templates:
      joinTo:
        "js/app.#{hash}.js": /^app\/templates(\/|\\)(.+)\.pug$/

  framework: "backbone"
