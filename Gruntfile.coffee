module.exports = (grunt) ->
  pkg = grunt.file.readJSON 'package.json'
  for taskName of pkg.devDependencies when taskName.substring(0, 6) is 'grunt-'
    grunt.loadNpmTasks taskName

  grunt.initConfig
    coffee:
      compile:
        files:
          'static/main.js': 'assets/coffee/main.coffee'
    less:
      development:
        files:
          'static/main.css': 'assets/less/main.less'
