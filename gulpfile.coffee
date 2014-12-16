'use strict'
routes     = require './server/server.coffee'
express    = require 'express'
livereload = require 'connect-livereload'
gulp       = require 'gulp'
bower      = require 'gulp-bower'
gutil      = require 'gulp-util'
coffee     = require 'gulp-coffee'
rimraf     = require 'gulp-rimraf'
inject     = require 'gulp-inject'
using      = require 'gulp-using'
less       = require 'gulp-less'
concat     = require 'gulp-concat'
template   = require 'gulp-template'
tinylr     = require 'tiny-lr'

watch      = require 'gulp-watch'
imagemin   = require 'gulp-imagemin'
uglify     = require 'gulp-uglify'
cssmin     = require 'gulp-cssmin'
karma      = require 'gulp-karma'
rename     = require 'gulp-rename'
moment     = require 'moment'

app = express()

EXPRESS_PORT = 5000
LIVERELOAD_PORT = 35729
lr = undefined
time = start = end = 0
EXPRESS_ROOT = __dirname + '/public/'

refresh = (event) ->
	timeout = setTimeout ->
		for method of app.routes
			app.routes[method] = [] # clean the routes
		delete require.cache[require.resolve routes] # remove the server module from cache
		routes app # rerun the module
	                                
		fileName = require('path').relative EXPRESS_ROOT, event.path
		gutil.log.apply gutil, [gutil.colors.magenta(fileName), gutil.colors.cyan('changed')]
		lr.changed body:
			files: [fileName]
	, 1000

removeFolders = [
	'./bower_components/' 
	'./public/'
]

concat_vendors = [
	'./bower_components/jquery/jquery.js'
	'./bower_components/angular/angular.js'
	'./src/scripts/libs/jquery.signalR-2.0.0.js'
	'./bower_components/angular-resource/angular-resource.js'
	'./bower_components/angular-route/angular-route.js'
	'./bower_components/angular-bootstrap/ui-bootstrap-tpls.js'
	'./bower_components/jquery-ui/jquery-ui.js'
	'./src/scripts/libs/mqa.toolkit.js'
]

concat_scripts = [
	'./bower_components/**/module/*.coffee'
	'./bower_components/**/scripts/*.coffee'
	'./src/scripts/**/*.coffee'
	'./src/config/production.coffee'
]

less_src = [
	'./src/styles/custom/styles.less'
	'./bower_components/bootstrap/less/bootstrap.less'
]

testFiles = [
	'public/scripts/vendors.js'
	'public/scripts/scripts.js'
	'test/libs/angular-mocks.js'
	'test/scripts/directives/*.coffee'
]

gulp.task 'start', ->
	start = new Date()

gulp.task 'end', ->
	end = new Date()
	time = end - start
	console.log moment(time).format('mm:ss.SSS')

gulp.task 'clean', ->
	gulp.src(removeFolders)
		.pipe(rimraf())

gulp.task 'bower', () ->
	bower('./bower_components')

gulp.task 'connect', ->
	app.configure ->
		app.use express.logger 'dev'
		app.use express.bodyParser()
		app.use express.methodOverride()
		app.use express.errorHandler()
		app.use livereload()
		app.use express.static EXPRESS_ROOT
		app.use app.router
		routes app

	app.listen EXPRESS_PORT
	lr = tinylr()
	lr.listen LIVERELOAD_PORT
	return

gulp.task 'coffee:scripts', ->
	gulp.src('./src/**/*.coffee')
		.pipe(coffee(bare: true).on('error', gutil.log))
		.pipe(gulp.dest('public'))

gulp.task 'coffee:vendors', ->
	gulp.src('./bower_components/**/*.coffee')
		.pipe(coffee(bare: true).on('error', gutil.log))
		.pipe(gulp.dest('public/vendors'))

gulp.task 'copy:vendors', ->
	gulp.src('./bower_components/**/*.js')
		.pipe(gulp.dest('public/vendors'))

gulp.task 'copy:vendors_views', ->
	gulp.src('./bower_components/**/views/*.html')
		.pipe(gulp.dest('public/vendors'))

gulp.task 'copy:src_views', ->
	gulp.src('./src/views/*.html')
		.pipe(gulp.dest('public/views'))

gulp.task 'images:dev', ->
	gulp.src('src/img/**/*.png')
		.pipe(gulp.dest('public/img'))

gulp.task 'images:prod', ->
	gulp.src('src/img/**/*.png')
		.pipe(imagemin())
		.pipe(gulp.dest('public/img'))

gulp.task 'copy:fonts', ->
	gulp.src('src/styles/fonts/*.*')
		.pipe(gulp.dest('public/styles/fonts/'))

gulp.task 'concat:vendors', ->
	gulp.src(concat_vendors)
		.pipe(concat('vendors.js'))
		.pipe(uglify())
		.pipe(gulp.dest('public/scripts/'))

gulp.task 'concat:scripts', ->
	gulp.src(concat_scripts)
		.pipe(coffee(bare: true).on('error', gutil.log))
		.pipe(concat('scripts.js'))
		#.pipe(uglify())
		.pipe(gulp.dest('public/scripts/'))

gulp.task 'less:dev', ->
	gulp.src(less_src)
		.pipe(less())
		.pipe(concat('styles.css'))
		.pipe(gulp.dest('public/styles/custom/'))

gulp.task 'less:prod', ->
	gulp.src(less_src)
		.pipe(less())
		.pipe(concat('styles.css'))
		.pipe(cssmin())
		.pipe(rename({suffix: '.min'}))
		.pipe(gulp.dest('public/styles/custom/'))

gulp.task 'copy:prod', ->
	gulp.src('./public/**/*.*')
		.pipe(gulp.dest('../Server/Application'))

gulp.task 'index:dev', ->	
	target = gulp.src('./src/index.html')
	sources = gulp.src([
		'vendors/jquery/jquery.js'
		'vendors/**/angular.js'
		'vendors/**/angular-resource.js'
		'vendors/**/angular-route.js'
		'vendors/**/ui-bootstrap-tpls.js'
		'vendors/**/jquery-ui.js'
		'scripts/libs/mqa.toolkit.js'
		'vendors/**/module/*.js'
		'vendors/**/scripts/*.js'
		'!**/test/**'
		'config/development.js'
		'scripts/app.js'
		'scripts/routes.js'
		'scripts/responseInterceptors/*.js'
		'scripts/controllers/**/*.js'
		'scripts/directives/**/*.js'
		'scripts/services/**/*.js'
		'scripts/filters/**/*.js'
		'scripts/resources/**/*.js'
	],
	read: false
	cwd: "" + __dirname + "/public/"
	)
	target.pipe(inject(sources),{ignorePath: 'public'})
		.pipe gulp.dest('public')

gulp.task 'index:prod', ->	
	target = gulp.src('./src/index.html')
	sources = gulp.src([
		'scripts/vendors.js'
		'scripts/scripts.js'
	],
	read: false
	cwd: "" + __dirname + "/public/"
	)
	target.pipe(inject(sources),{ignorePath: 'public'})
		.pipe gulp.dest('public')

gulp.task 'template:dev', ->
	gulp.src('public/index.html')
		.pipe(template({config: {env: 'dev'}}))
		.pipe(gulp.dest('public/'))
	gulp.start 'end'

gulp.task 'template:prod', ->
	gulp.src('public/index.html')
		.pipe(template({config: {env: 'prod'}}))
		.pipe(gulp.dest('public/'))

gulp.task 'watch', ->
	gulp.watch(['src/**/**.coffee'], ['coffee:scripts'])
	gulp.watch(['src/**/**.less'], ['less:dev'])
	gulp.watch(['src/views/**.html'], ['copy:src_views'])
	gulp.watch(['src/index.html'], ['injectFiles:dev'])
	gulp.watch(['src/**'],  refresh)

gulp.task 'test', ->
	gulp.src(testFiles).pipe(karma(
		configFile: "test/karma.conf.js"
		action: "run"
	)).on "error", (err) ->
		throw err

gulp.task 'injectFiles:dev', ['index:dev'], () -> 
	gulp.start 'template:dev'

gulp.task 'injectFiles:prod', ['index:prod'], () -> 
	gulp.start ['template:prod', 'copy:prod']

gulp.task 'build:dev', [
	'connect'
	'watch'
	'copy:vendors'
	'coffee:scripts' 
	'coffee:vendors' 
	'copy:vendors_views' 
	'copy:src_views'
	'less:dev'
	'copy:fonts'
	'images:dev'
	], () ->
		gulp.start 'injectFiles:dev'

gulp.task 'build:prod', [
	'concat:vendors'
	'concat:scripts'
	'copy:vendors_views' 
	'copy:src_views'
	'less:prod'
	'copy:fonts'
	'images:prod'
	], () ->
		gulp.start 'injectFiles:prod'

gulp.task 'server', ['start', 'bower'], () ->
	gulp.start 'build:dev'

gulp.task 'prod', ['bower'], () ->
	gulp.start 'build:prod'

gulp.task 'localprod', ['bower'], () ->
	gulp.start ['connect', 'build:prod']