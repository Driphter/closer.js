module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    shell:
      jison:
        command: 'jison src/grammar.y src/lexer.l -o lib/parser.js'
        options:
          failOnError: true

      browserify:
        command: 'browserify -s <%= pkg.name %> lib/<%= pkg.name %>.js > dist/<%= pkg.name %>.js;
          browserify -s <%= pkg.name %>-core lib/<%= pkg.name %>-core.js > dist/<%= pkg.name %>-core.js;
          browserify -s <%= pkg.name %>-spec lib/spec/<%= pkg.name %>-spec.js > demo/js/<%= pkg.name %>-spec.js;
          browserify -s <%= pkg.name %>-core-spec lib/spec/<%= pkg.name %>-core-spec.js > demo/js/<%= pkg.name %>-core-spec.js;'
        options:
          failOnError: true

      copy_uglified:
        command: 'cp dist/<%= pkg.name %>-core.js demo/js/<%= pkg.name %>-core.js;
                  cp dist/<%= pkg.name %>.js demo/js/<%= pkg.name %>.js;'
        failOnError: true

      push_ghpages:
        command: 'git subtree push --prefix demo origin gh-pages'
        options:
          failOnError: true

    jasmine_node:
      all: ['lib/spec/']
      options:
        showColors: true
        includeStackTrace: false
        forceExit: true

    watch:
      files: ['src/lexer.l', 'src/grammar.y', 'src/**/*.coffee', 'spec/**/*.coffee']
      tasks: ['default']
      options:
        spawn: true
        interrupt: true
        atBegin: true
        livereload: true

    coffeelint:
      app: ['src/**/*.coffee', 'spec/**/*.coffee']
      options:
        max_line_length:
          level: 'ignore'
        line_endings:
          value: 'unix'
          level: 'error'

    coffee:
      compile:
        files: [
          expand: true         # Enable dynamic expansion.
          cwd: 'src/'          # Src matches are relative to this path.
          src: ['**/*.coffee'] # Actual pattern(s) to match.
          dest: 'lib/'         # Destination path prefix.
          ext: '.js'           # Dest filepaths will have this extension.
        ,
          expand: true         # Enable dynamic expansion.
          cwd: 'spec/'         # Src matches are relative to this path.
          src: ['**/*.coffee'] # Actual pattern(s) to match.
          dest: 'lib/spec/'    # Destination path prefix.
          ext: '.js'           # Dest filepaths will have this extension.
        ]

    uglify:
      parser:
        files:
          'dist/<%= pkg.name %>.js': ['dist/<%= pkg.name %>.js']
      core:
        files:
          'dist/<%= pkg.name %>-core.js': ['dist/<%= pkg.name %>-core.js']

  grunt.loadNpmTasks 'grunt-shell'
  grunt.loadNpmTasks 'grunt-jasmine-node'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-uglify'

  grunt.registerTask 'default', ['coffeelint', 'coffee', 'shell:jison', 'jasmine_node', 'shell:browserify', 'uglify', 'shell:copy_uglified']
  grunt.registerTask 'test', ['coffeelint', 'coffee', 'shell:jison', 'jasmine_node']
  grunt.registerTask 'build', ['coffeelint', 'coffee', 'shell:jison']
  grunt.registerTask 'push_demo', ['shell:push_ghpages']
