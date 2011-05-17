fs = require 'fs'
{exec} = require 'child_process'

appFiles = [
  'aws'
  'client'
]

task 'build', 'Build javascript portion of the app', ->
  appContents = new Array remaining = appFiles.length
  for file, index in appFiles then do (file, index) ->
    fs.readFile "coffee/#{file}.coffee", 'utf8', (err, fileContents) ->
      throw err if err
      appContents[index] = fileContents
      process() if --remaining is 0
  process = ->
    fs.writeFile 'extension/lib/js/app.coffee', appContents.join('\n\n'), 'utf8', (err) ->
      throw err if err
      exec 'coffee --compile extension/lib/js/app.coffee', (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr
        fs.unlink 'extension/lib/js/app.coffee', (err) ->
          throw err if err
          console.log 'Done.'

task 'clean', 'Clean the build', ->
  fs.unlink 'extension/lib/js/app.js', (err) ->
    throw err if err
    console.log 'Cleaned.'
