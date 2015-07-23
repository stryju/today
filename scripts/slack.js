var https = require( 'https' );

process.stdin.setEncoding( 'utf8' );

var log = '';

process.stdin.on( 'readable', function() {
  var chunk = process.stdin.read();
  if (chunk !== null) {
    log += chunk;
  }
});

process.stdin.on('end', function() {
  var lines = log.split( /\r?\n/ )
    .filter( function ( line ) {
      return /^\++\d+\.\s+/.test( line );
    })
    .map( function ( line ) {
      return ' - ' +
        line
          .replace( /^\++\d+\.\s+/, '' )
          .replace( /\[([^\]]+)\]\(([^\s]+)\)/g, '<$2|$1>' )
          .replace( /<\/?q>/g, '"' );
    });

  if ( ! lines.length ) {
    return;
  }

  var payload = {
    username   : "tom’s today",
    icon_emoji : ":shipit:",
    text       : 'new content:\n' + lines.join( '\n' )
  };

  send( JSON.stringify( payload ) );
});

function send( formData ) {
  var config = {
    hostname : 'hooks.slack.com',
    port     : 443,
    path     : '/services/' + process.argv[ 2 ],
    method   : 'POST'
  };

  var req = https.request( config, function( res ) {
    res.setEncoding( 'utf8' );
    res.on( 'data', function( d ) {
      process.stdout.write( d );
    });
  });

  req.write( formData );
  req.end();
}
