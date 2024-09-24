function root = getrootdir()
% throw the root directory depending on the name of the computer
pc = getenv( 'computername' );
switch pc
    case { 'AJAX', 'NEUROPIXELS' }
        root = 'D:\Dropbox (Personal)\Projects\034_DARPA_ABC\';
        
    case 'ACHILLES'
        root = 'E:\Dropbox (Personal)\Projects\034_DARPA_ABC\';
        
    case 'ZENZEN'
        root = 'C:\Users\Isabella\Dropbox (Personal)\034_DARPA_ABC\';
        
    case 'BBU-PC'
        root = 'E:\Dropbox (MIT)\034_DARPA_ABC\';
        
    case 'HADES'
        root = 'D:\Dropbox (Personal)\034_DARPA_ABC\';

    case 'ODYSSEUS'
        root = 'C:\Users\Pancho\Dropbox (Personal)\Projects\034_DARPA_ABC\';
        
    otherwise
        error( 'Unknown Computer' )
        
end