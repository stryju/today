// jshint esnext:true

var marked = require( 'marked' );
var opts   = { encoding : 'UTF-8' };

require( 'fs' ).readFile( process.argv[ 2 ], opts, function( err, md ) {
  if ( err ) {
    process.exit( 1 );
    return;
  }

  md = marked( md ).replace( /([\&/"])/g, '\\$1' ).replace( /\n/g, ' ' );

  process.stdout.write( md );
  process.exit( 0 );
});
