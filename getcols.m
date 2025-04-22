function cols = getcols( opts, str, where )
% GETCOLS gets the names of columns that contain a given string
% 
% Usage:
% cols = getcols( opts, str, where )
% 
% Input:
% opts: table options from 'detectImportOptions'.
% str: target string to search for.
% where: Optional. Where the target string can be located. Either
% 'anywhere', 'begining', or 'end'. Default: anywhere.
% 
% Output:
% cols: cell array with column names that contain the target string.

if ~exist( "where", "var" )
    where = 'anywhere';

end


switch where
    case 'anywhere'
        tmp = regexp( opts.VariableNames, str );

    case 'begining'
        tmp = regexp( opts.VariableNames, strcat( '^', str ) );

    case 'end'
        tmp = regexp( opts.VariableNames, strcat( str, '$' ) );

end

cnt = 1;
for colIdx = 1 : length( tmp )
    thisCol = tmp{ colIdx };

    if ~isempty( thisCol )
        idx( cnt ) = colIdx;
        cnt = cnt + 1;

    end

end

cols = opts.VariableNames( idx );