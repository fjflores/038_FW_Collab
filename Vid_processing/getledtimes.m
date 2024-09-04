function ledTimes = getledtimes( lumDat )
% GETLEDTIMES finds the on and off times of led's in videos.
%
% Usage:
% ledTimes = getledtimes( lumDat )
%
% Input:
% lumDat: luminance data as a 1D vector of integers between 0 and 255.
%
% Output:
% ledTimes: matrix of on and off times in time x [ on off ].

% fix lumDat with hairy peaks
% fixThresh = floor( max( lumDat ) * 0.9 );
% lumDat( lumDat > fixThresh ) = fixThresh;

% Now find peaks
pkThresh = floor( max( lumDat / 2 ) );
[ ~, pkLocsOn ] = findpeaks( lumDat,...
    'MinPeakHeight', pkThresh,...
    'MinPeakWidth', 100 );
[ ~, tempOff ] = findpeaks( flip( lumDat ),...
    'MinPeakHeight', pkThresh,...
    'MinPeakWidth', 100 );
pkLocsOff = flip( length( lumDat ) - tempOff );
% ledTimes = [ pkLocsOn pkLocsOff + 1 ]; % offset OFF by 1.
ledTimes = sort( [ pkLocsOn; pkLocsOff + 1 ] );


end

