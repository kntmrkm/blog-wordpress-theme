webpackStream    = require "webpack-stream"
webpack    = require "webpack"

source     = require "vinyl-source-stream"
buffer     = require "vinyl-buffer"
runSequence = require "run-sequence"
path       = require "path"

glob       = require "glob"
del        = require "del"

gulp       = require "gulp"
notify     = require "gulp-notify"
rename     = require "gulp-rename"
plumber    = require "gulp-plumber" # エラーによるwatch実行中断防止
concat     = require "gulp-concat"
bower      = require "gulp-bower"
bowerFiles = require "main-bower-files"
uglify     = require "gulp-uglify"

minifyCSS  = require "gulp-minify-css"
compass    = require "gulp-compass"
sass       = require "gulp-sass" #sass       = require "gulp-ruby-sass"

paths =
  srcFiles: glob.sync("./app/*.js")
  build: "./public/"
  cssBuildPath: "style.css"
  jsBuildFile: "app.js"
  nodeModules: "./node_modules"
  bowerComponents: "./bower_components"

gulp.task "css", ->
  #gulp.src "./app/styles/mobile.scss"
  #  .pipe sass()
  #  .pipe gulp.dest "./public"

  #gulp.src "./app/styles/**/*.scss"
  gulp.src "./src/style.scss"
    .pipe plumber()
    .pipe(compass(
      config_file: "./compass/config.rb"
      bundle_exec: true
      comments: false
      cache: false
      http: "./"
      css: "./"
      sass: "./src"
    ))
    .pipe minifyCSS()
    .pipe gulp.dest "./"

gulp.task "js", ->
  #gulp.src(paths.nodeModules + "/react/dist/react.min.js")
  #  .pipe gulp.dest "./public/"  

  gulp.src "./src/"
  .pipe webpackStream {
    progress: true
    entry: 
      app: "./app/initialize.coffee"
    output:
      filename: paths.jsBuildFile
    resolve:
      root: [path.join(__dirname, "./")]
      moduleDirectories: ["node_modules", "bower_components"]
      extensions: ["", ".js", ".coffee"]
    externals: {},
    module:
      loaders: [
        { test: /\.coffee$/, loader: "coffee-loader" },
      ]
    plugins: [ 
      new bowerWebpackPlugin(),
      new webpack.optimize.AggressiveMergingPlugin(),
      new webpack.optimize.DedupePlugin(),
      new webpack.ProvidePlugin
        $: "jquery"
    ]
  }
  .pipe plumber()
  .pipe uglify()
  .pipe gulp.dest paths.build

gulp.task "asset", ->
  gulp.src(paths.nodeModules + "/font-awesome/fonts/**.*")
    .pipe gulp.dest "./public/fonts/font-awesome"

gulp.task "lib", ->
  return bower()
    .pipe gulp.src(bowerFiles("**/*.js"))
    .pipe plumber()
    .pipe concat("lib.js")
    .pipe gulp.dest paths.build

gulp.task "watch", ["build"], ->
  gulp.watch "src/**/*.scss", ["css"]
  #gulp.watch "src/**/*.js", ["js"]
  #gulp.watch "src/**/*.coffee", ["js"]
  #gulp.watch "bower_components/**/*.js", ["lib"]

gulp.task "clean", ->
  del.sync("./style.css")

gulp.task "build", ->
  return runSequence(
    "clean"
    "css"
  )  

gulp.task "default", ["watch"]



