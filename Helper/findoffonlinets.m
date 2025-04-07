%% Little script to find dex and ati off/online timestamps.

% 1) Use data tips to find all 4 timestamps (dex offline, dex online, ati
% offline, ati online).

% 2) Right click in figure and hit "Export Cursor Data to Workspace".

% 3) Run code below.
for i = 1 : length( cursor_info )
    tsOffOnLine( i ) = cursor_info( i ).Position( 1 );
end

tsOffOnLine = sort( tsOffOnLine );
tsOffOnLine( 1 : 2 : end ) = floor( tsOffOnLine( 1 : 2 : end ) );
tsOffOnLine( 2 : 2 : end ) = ceil( tsOffOnLine( 2 : 2 : end ) );

% 4) Copy and paste timestamps (in variable "tsOffOnLine") into metadata 
% Excel file.