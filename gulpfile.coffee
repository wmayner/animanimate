del = require 'del'
gulp = require 'gulp'
pug = require 'gulp-pug'
shell = require 'gulp-shell'
watch = require 'gulp-watch'

SRC_DIR = './src'
LIB_DIR = './lib'
APP_DIR = './app'

STYLUS_DIR = "#{SRC_DIR}/css"
STYLUS_FILES = "#{STYLUS_DIR}/**/*.styl"

PUG_DIR = SRC_DIR
PUG_FILES = "#{PUG_DIR}/**/*.pug"

COFFEE_DIR = "#{SRC_DIR}/js"
COFFEE_FILES = "#{COFFEE_DIR}/**/*.coffee"
COFFEE_CMD = './node_modules/coffee-script/bin/coffee'

ENTRYPOINT = "#{LIB_DIR}/app.js"

gulp.task 'clean:html', -> del "#{APP_DIR}/*.html"

gulp.task 'clean:js', -> del ["#{LIB_DIR}/*", "#{APP_DIR}/js/*.js"]

gulp.task 'clean:css', -> del "#{APP_DIR}/css/*.css"

gulp.task 'clean', ['clean:html', 'clean:js', 'clean:css']

gulp.task 'compile:pug', ['clean:html'], ->
    gulp.src PUG_FILES
        .pipe pug({pretty: true})
        .pipe gulp.dest(APP_DIR)

gulp.task 'compile:stylus', ['clean:css'], shell.task(
  # Compile with line numbers and sourcemaps
  "./node_modules/stylus/bin/stylus -l -m #{STYLUS_DIR}/app.styl -o #{APP_DIR}/css"
)

gulp.task 'compile:coffee', ['clean:js'], shell.task(
  "#{COFFEE_CMD} -c -o #{LIB_DIR} #{COFFEE_DIR}",
)

gulp.task 'browserify', ['compile:coffee'], shell.task(
  "./node_modules/browserify/bin/cmd.js #{ENTRYPOINT} --no-cache -o #{APP_DIR}/js/app.js",
)

gulp.task 'build', ['compile:pug', 'compile:stylus', 'browserify']

gulp.task 'watch:pug', ['compile:pug'], ->
  gulp.watch(PUG_FILES, ['compile:pug'])

gulp.task 'watch:stylus', ['compile:stylus'], ->
  gulp.watch(STYLUS_FILES, ['compile:stylus'])

gulp.task 'watch:coffee', ['browserify'], ->
  gulp.watch(COFFEE_FILES, ['browserify'])

gulp.task 'dev', ['build', 'watch:pug', 'watch:stylus', 'watch:coffee']

gulp.task 'default', ['dev']
