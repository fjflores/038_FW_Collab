function T = safereadtable( tab2read )
% SAFEREADTABLE ensure numerical columns when they should.
%
% Usage:
% safeTab = safereadtable( tab2read )
%
% Inputs:
% tab2read: path to table to read, typically an excel file.
% 
% Outputs:
% T: table with numerical columns as numerical columns.

msg = sprintf( "The number of columns is assumed to be fix and is hardcoded.\n If you have added columns after 28-Apr-2025, update this fx." );
warning( msg )
    

% Get the variable names of the table
opts = detectImportOptions( tab2read );
varNames = opts.VariableNames;
logicalCols = [ 2 3 34 35 36 ];
doubleCols = [ 1 7 8 9 37 : 43 ];
strCols = [ 4 5 6 10 : 33 44 ];
opts = setvartype( opts, varNames( logicalCols ), 'logical' );
opts = setvartype( opts, varNames( doubleCols ), 'double' );
opts = setvartype( opts, varNames( strCols ), 'string' );
T = readtable( tab2read, opts );

