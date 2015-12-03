program = require('commander')
SSH = require('node-sshclient').SSH
fs = require('fs')

config = require('../config')

# SSH to file archive and get listing.
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
# Handle command line arguments.
#
program
  .version('0.0.1')

program
  .command('files')
  .description('gets list of files in DVD archive directory and saves to dvds.json.')
  .action(get_file_listing)

program.parse(process.argv)
