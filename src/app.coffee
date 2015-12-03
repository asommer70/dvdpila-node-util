program = require('commander')

# SSH to file archive and get listing.
get_file_listing = () ->
  console.log('Getting archive file listing...')








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
