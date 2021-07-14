_    = require("lodash")
fs   = require("fs")
data = require("./utils/data")
git  = require("git-rev-sync")
glob = require("glob")
hash = git.short()

if process.env.NODE_ENV is "development"
  glob "app/static/**/*.pug", (err, list) ->
    console.log(list
      .filter((e) -> not e.match("/_"))
      .filter((e) -> not e.match(/partials|survey-results\/q/))
      .map((e) ->
        e
          .replace("app/static/", "http://localhost:4000/")
          .replace("index.pug", "")
          .replace(".pug", ".html")
      )
      .join("\n")
    )

marked = (data) ->
  require("marked")(data, { smartypants: true, headerIds: false })
    .replace(
      /(<a href="http[^>]+)>/g,
      "$1 target=\"_blank\" rel=\"noreferrer\">"
    )

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
        package:  require("./package.json")
        marked:   marked
        data:     data
        version:  hash
        r:  ->
          delete require.cache[require.resolve arguments[0]]
          require(arguments[0])
      filters:
        sass: (data) ->
          require("node-sass").renderSync({
            data
            indentedSyntax: true
          }).css.toString()

        coffee: (data) ->
          require("coffeescript").compile(data)

        marked: marked

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
          "vendor/js/underscore.js"
          "vendor/js/jquery.js"
          "vendor/js/moment.js"
          "vendor/js/backbone.js"
        ]

    stylesheets:
      joinTo:
        "css/app.#{hash}.css": "app/sass/app.sass"

    templates:
      joinTo:
        "js/app.#{hash}.js": /^app\/templates(\/|\\)(.+)\.pug$/

  framework: "backbone"
