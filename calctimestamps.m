% Little script to calculate timestamps in seconds based on times written
% in hh:mm:ss format.

rec = datetime( 1, 1, 1, 13, 36, 15 );
dex = datetime( 1, 1, 1, 14, 09, 20 );
ati = datetime( 1, 1, 1, 15, 10, 00 );

difDex = between( rec, dex );
difDex = time( difDex );
difDex = seconds( difDex );

difAti = between( rec, ati );
difAti = time( difAti );
difAti = seconds( difAti );

fprintf( 'Dex: %i; Ati: %i\n', difDex, difAti )