function ledTimes = getledtimes( lumDat, kind, nSampPulse, tol )
% GETLEDTIMES finds the on and off times of led's in videos.
%
% Usage:
% ledTimes = getledtimes( lumDat, kind, nSampPulse, tol )
%
% Input:
% lumDat: luminance data as a 1D vector of integers between 0 and 255.
% kind: 'bonsai' for DBS experiments using Bonsai software to collect 
% led.csv (default). 'old' for old TI videos.
% nSampPulse: duration of led on event in samples (only needed for 'old'
% kind).
% tol: tolerance of samples around pulseDur (only needed for 'old' kind). 
% Default 2 (+-1).
%
% Output:
% ledTimes: matrix of on and off times in time x [ on off ].

% Set defaults.
if nargin < 2
    kind = 'bonsai';
    
end

if nargin < 3 && strcmpi( kind, 'old' )
    error( 'Must input nSampPulse if kind = ''old''.' )
    
end
    
if nargin < 4 && strcmpi( kind, 'old' )
    tol = 2;
    funCallStack = dbstack;
    fxName = funCallStack(1).name;
    fprintf( '%s: Using default tolerance of %u\n', fxName, tol )
    
end

switch kind
    case 'bonsai'
        % fix lumDat with hairy peaks 
        fixThresh = floor( max( lumDat / 2 ) );
        lumDat( lumDat > fixThresh ) = fixThresh;
        
        % Now find peaks
        pkThresh = floor( max( lumDat / 2 ) );
        [ ~, pkLocsOn ] = findpeaks( lumDat,...
            'MinPeakHeight', pkThresh,...
            'MinPeakWidth', 20 );
        [ ~, tempOff ] = findpeaks( flip( lumDat ),...
            'MinPeakHeight', pkThresh,...
            'MinPeakWidth', 20 );
        pkLocsOff = flip( length( lumDat ) - tempOff );
        ledTimes = [ pkLocsOn pkLocsOff + 1 ]; % offset OFF by 1.
        
    case 'old'
        dLum = diff( lumDat );
        [ ~, pkLocs ] = findpeaks( abs( dLum ),...
            'MinPeakHeight', 80 );
        
        % test durations
        cnt = 1;
        for i = 1 : numel( pkLocs ) - 1
            test = pkLocs( i );
            testVec = pkLocs( i + 1 : end );
            
            for j = 1 : numel( testVec )
                testVal = testVec( j ) - test;
                
                if testVal > nSampPulse - tol  && testVal < nSampPulse + tol
                    ledTimes( cnt, 1 : 2 ) = [ test testVec( j ) ]; %#ok<AGROW>
                    fprintf( 'Iter: %u cnt: %u start: %u end: %u, dur: %u\n',...
                        i, cnt, test, testVec( j ), testVal )
                    cnt = cnt + 1;
                    
                end
                
            end
            
        end
        
end


end

