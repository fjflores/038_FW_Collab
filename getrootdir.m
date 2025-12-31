function root = getrootdir( kind )
% throw the root directory depending on the name of the computer
if nargin < 1
    kind = "local";

end
kind = string( kind );

pc = getenv( 'computername' );
switch pc
    case { 'AJAX', 'NEUROPIXELS' }
        if strcmp( kind, "local" )
            root = 'D:\Dropbox (Personal)\Projects\038_Analgesia_Torpor\';

        elseif strcmp( kind, "remote" )
            error( "Remote root dir is undefined" )

        end

    case 'ACHILLES'
        if strcmp( kind, "local" )
            root = 'E:\Dropbox (Personal)\Projects\038_Analgesia_Torpor\';

        elseif strcmp( kind, "remote" )
            root = 'N:\038_Analgesia_Torpor\';

        end

    case 'ZENZEN'
        root = 'C:\Users\Isabella\Dropbox (Personal)\038_Analgesia_Torpor\';

    case 'BBU-PC'
        root = 'E:\Dropbox (MIT)\038_Analgesia_Torpor\';

    case 'HADES'
        if strcmp( kind, "local" )
            root = 'D:\Dropbox (Personal)\038_Analgesia_Torpor';

        elseif strcmp( kind, "remote" )
            root = 'N:\038_Analgesia_Torpor\';

        end

    case 'ODYSSEUS'
        if strcmp( kind, "local" )
            root = 'C:\Users\Pancho\Dropbox (Personal)\Projects\038_Analgesia_Torpor\';

        elseif strcmp( kind, "remote" )
            error( "Remote root dir is undefined" )

        end

    otherwise
        error( 'Unknown Computer' )

end