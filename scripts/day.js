try {
  var date = new Date( process.argv[ 2 ] );
  var days = [ 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' ];

  process.stdout.write( days[ date.getDay() ] );
  process.exit( 0 );
} catch ( e ) {
  process.exit( 1 );
}
