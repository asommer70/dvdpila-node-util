program = require('commander')
fs = require('fs')
SSH = require('node-sshclient').SSH
pg = require('pg')

config = require('../config')
file_dvds = require('../dvds')


#
# SSH to file archive and get listing.
#
get_file_listing = () ->
  # Setup SSH connection.
  ssh = new SSH({
    hostname: config.server.hostname,
    user: config.server.username,
    port: 22
  })

  # List files in archive and write to dvds.json file.
  ssh.command 'ls', config.server.archive, (procResult) ->
    dvds = { dvds: procResult.stdout.split("\n") }

    fs.writeFile 'dvds.json', JSON.stringify(dvds, null, 2), (err) ->
      if (err)
        return console.log(err);

    console.log("#{dvds.dvds.length} dvds written to dvds.json")

#
# Compare DVDs in dvds.json to the DVDs created in the DVD Pila! database.
#
compare_dvds = () ->
  fs.exists 'dvds.json', (exists) ->
    if not exists
      console.log('Getting DVDs from archive...')
      get_file_listing()

  # Setup DVD Pila! database connection.
  conString = "postgres://#{config.dvdpila.db_username}:#{config.dvdpila.db_password}@#{config.dvdpila.db_hostname}/#{config.dvdpila.database}"
  pg.connect conString, (err, client, done) ->
    if err
      console.error('error fetching client from pool', err)

    # Get a list of all DVDs in the database.
    client.query 'select id, file_url from dvds;', (err, result) ->
      done()

      if err
        console.error('error running query', err)

      # Get just the DVD name.
      dvds = []
      for dvd in result.rows
        if dvd.file_url?
          parts = dvd.file_url.split('/')
          file_name = parts[parts.length - 1]
          dvds.push(file_name)

      # Get a list of files not in DVD Pila!.
      unentered = []
      for file_dvd in file_dvds.dvds
        # if not dvds.indexOf(file_dvd)
        #   unentered.push(file_dvd)
        if file_dvd not in dvds
          unentered.push(file_dvd)

      console.log(unentered)
      console.log("#{unentered.length} files aren't linked to DVDs.")


#
# Handle command line arguments.
#
program
  .version('0.0.1')

program
  .command('files')
  .description('Gets list of files in DVD archive directory and saves to dvds.json.')
  .action(get_file_listing)

program
  .command('compare_dvds')
  .description('Compare DVDs in dvds.json to the DVDs created in the DVD Pila! database.')
  .action(compare_dvds)

program.parse(process.argv)
