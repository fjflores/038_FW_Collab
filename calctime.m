rec = datetime( 1, 1, 1, 16, 20, 55 );
dex = datetime( 1, 1, 1, 16, 53, 30 );
ati = datetime( 1, 1, 1, 17, 55, 00 );

difDex = between( rec, dex );
difDex = time( difDex );
difDex = seconds( difDex );

difAti = between( rec, ati );
difAti = time( difAti );
difAti = seconds( difAti );

fprintf( 'Dex: %i; Ati: %i\n', difDex, difAti )