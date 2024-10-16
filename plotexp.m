function [ hAx, hLink ] = plotexp( expId, varargin )
% PLOTEXP plots raw and precessed experiments.
%
% Usage:
% [ hAx, hLink ] = plotexp( ephysData, Name, Value )
% 
% This function plots eeg, spectrograms, coherence, emg/activation, and
% video speed data (if exists). The epochs during which stimulation was
% delivered are highlighted. There are a number of options to control what
% and how it is shown.
%
% Input:
% ephysData: structure with processed data for a given experiment.
% 
% Plotting options as Name-Value pairs:
%   SetShowEeg: 'all' shows raw and filtered lfp. 'filt' and 'raw' are
%   obvious. Deafault 'all'.
%
%   SetAmpEeg: Two-element vector with amplitude limits for lfp. Default
%   [-500 500].
%
%   SetFreqSpec: Two-element vector with frequency range for spectrograms
%   and coherence. Default: all calculated frequencies.
%
%   SetTime: 'all' show all the experiment. Otherwise a two-element vector
%   with the time segment to show, in minutes. Default 'all'.
%
%   SetCAxis: 'auto' sets the color axis of the time-frequency plots 
%   between the 5th and 99th percentiles. Otherwise, a two-element vector 
%   with color axis values. Default 'auto'.
% 
%   SetShowEmg: 'raw' shows the unprocessed emg recording. 'smooth' shows
%   the estimated muscle activation. Default: 'smooth'.
% 
%   PlotEvents: 'yes' plots all events/TTLs. 'no' doesn't. Default: 'no'.
% 
%   MinOrSec: 'min' plots x-axis in minutes. 'sec' plots x-axis in seconds.
%   Default: 'min'.

% Load data to plot
[ coher, eegClean, eegFilt, emgFilt, emgRaw, events, spec ]...
    = loadprocdata( expId, 'plot' );


% Set options default values
showEeg = 'all';
yLimsEeg = [ -500 500 ];
yLimsSpec = spec.params.fpass;
xLims = 'all';
specLims = 'auto';
showEmg = 'smooth';
plotEvs = 'no';
minOrSec = 'min';

% Parse  name-value pairs
names = varargin( 1 : 2 : end );
values = varargin( 2 : 2 : end );
for k = 1 : numel( names )
    switch lower( names{ k } )
        case "setshoweeg"
            showEeg = values{ k };
            
        case "setampeeg"
            yLimsEeg = values{ k };
            
        case "setfreqspec"
            yLimsSpec = values{ k };
            
        case "settime"
            xLims = values{ k };
            
        case "setcaxis"
            specLims = values{ k };
            
        case "setshowemg"
            showEmg = values{ k };

        case "plotevents"
            plotEvs = values{ k };
            
        case "minorsec"
            minOrSec = values{ k };
            
        otherwise
            error( '''%s'' is not a valid Name for Name, Value pairs.',...
                names{ k } )
            
    end
    
end

if ~exist( "emgSmooth", "var" ) && strcmpi( showEmg, 'smooth' )
    showEmg = 'raw';
    warning( [ 'Smooth EMG doesn''t exist, so plotting ',...
        'raw EMG instead.' ] )
        
end

% Unpack data from structure.
% Color for lfp: raw is blue, filt is red.
cMapAll = flipud( brewermap( 2, 'Set1' ) );
if strcmpi( showEeg, 'all' ) || strcmpi( showEeg, 'both' )
    datPlot{ 1 } = [ eegClean.data( :, 1 ),...
        eegFilt.data( :, 1 ) ];
    datPlot{ 3 } = [ eegClean.data( :, 2 ),...
        eegFilt.data( :, 2 ) ];
    cMap = cMapAll;
    
elseif strcmpi( showEeg, 'filt' )
    datPlot{ 1 } = eegFilt.data( :, 1 );
    datPlot{ 3 } = eegFilt.data( :, 2 );
    cMap = cMapAll( 2, : );
    
elseif strcmpi( showEeg, 'raw' )
    datPlot{ 1 } = eegClean.data( :, 1 );
    datPlot{ 3 } = eegClean.data( :, 2 );
    cMap = cMapAll( 1, : );
    
end

datPlot{ 2 } = spec.S( :, :, 1 );
datPlot{ 4 } = spec.S( :, :, 2 );
datPlot{ 5 } = coher.C;

if strcmpi( showEmg, 'smooth' )
    datPlot{ 6 } = emgSmooth.data;
    emgLab = 'act';
    yLimEmg = [ 0 1 ];
           
elseif strcmpi( showEmg, 'raw' )
    datPlot{ 6 } = emgRaw.data;
    emgLab = 'Amp. (\muV)';
    yLimEmg = [ min( datPlot{ 6 } ) max( datPlot{ 6 } ) ];
    
elseif strcmpi( showEmg, 'filt' )
    datPlot{ 6 } = emgFilt.data;
    emgLab = 'Amp. (\muV)';
    yLimEmg = [ min( datPlot{ 6 } ) max( datPlot{ 6 } ) ];
    
end

dlcExist = exist( "dlc", "var" );
if dlcExist
    % get position and speed
    snoutSpeed = dlc.snoutSpeed;
    hipsSpeed = dlc.hipsSpeed;
    datPlot{ 7 } = [ snoutSpeed hipsSpeed ];
    yLimDlc = [ 0 max( datPlot{ 7 }, [ ], 'all' ) ] ;
    dlcLab = '|v| (cm/s)';
    
end

% Unpack timestamps from structure.
if strcmpi( minOrSec, 'min' )
    secConvers = 60;
    tUnits = 'min';

elseif strcmpi( minOrSec, 'sec' )
   secConvers = 1;
   tUnits = 'sec';

end

t2plot{ 1 } = eegClean.ts( :, 1 ) / secConvers;
t2plot{ 2 } = spec.t / secConvers;
t2plot{ 3 } = t2plot{ 1 };
t2plot{ 4 } = t2plot{ 2 };
t2plot{ 5 } = t2plot{ 2 };

switch showEmg
    case 'smooth'
        t2plot{ 6 } = emgSmooth.t / secConvers;
        
    case { 'raw', 'filt' }
        t2plot{ 6 } = t2plot{ 1 };
        
end

if dlcExist
    t2plot{ 7 } = dlc.t / secConvers;
    
end

f = spec.f;

if strcmpi( plotEvs, 'yes' )
    tsOn = events.tsOn;
    tsOff = events.tsOff;
    evTs = sort( [ tsOn; tsOff ] ) / secConvers; 

else  
    tsOn = [];
    tsOff = [];
    evTs = sort( [ tsOn; tsOff ] ) / secConvers; 
    
end

% tits = {...
%     'Frontal EEG ',...
%     'Frontal spectrogram',...
%     'Parietal EEG ',...
%     'Parietal spectrogram',...
%     'EMG' };

disp( 'Plotting experiment...' )
% figure( 'Position', [ 360 63 744 555 ])
nPlots = length( datPlot );
gap = [ 0.005 0.01 ];
margH = [ 0.1 0.05 ];
margV = [0.1 0.1];
opts = { gap, margH, margV };
for plotIdx = 1 : nPlots
    switch plotIdx
        case { 1, 3 }
            hAx( plotIdx ) = subtightplot( nPlots, 1, plotIdx, opts{ : } );
            plotevents( plotIdx, evTs, yLimsEeg );
            hold on
            colororder( cMap );
            thisEEGPlot = plot( t2plot{ plotIdx }, datPlot{ plotIdx } );
            thisEEGPlot(1).DataTipTemplate.DataTipRows(1).Format = '%.4f';
            if length( thisEEGPlot ) == 2
                thisEEGPlot(2).DataTipTemplate.DataTipRows(1).Format = '%.4f';
            end
            ylabel( 'Amp. (\muV)' )
            xticks( [ ] )
            xticklabels( {} )
            ylim( yLimsEeg )
            
            
        case { 2, 4 }
            hAx( plotIdx ) = subtightplot( nPlots, 1, plotIdx, opts{ : } );
            imagesc( t2plot{ plotIdx }, f, pow2db( datPlot{ plotIdx }' ) )
            axis xy
            ylabel( 'Freq. (Hz)' )
            xticks( [ ] )
            xticklabels( {} )
            hold on
            plotevents( plotIdx, evTs, [ f( 1 ) f( end ) ] );
            ffcbar( gcf, hAx( plotIdx ), 'Power (db)' );
            
        case 5
            hAx( plotIdx ) = subtightplot( nPlots, 1, plotIdx, opts{ : } );
            imagesc( t2plot{ plotIdx }, f, atanh(  datPlot{ plotIdx }' ) )
            axis xy
            ylabel( 'Freq. (Hz)' )
            xticks( [ ] )
            xticklabels( {} )
            hold on
            plotevents( plotIdx, evTs, [ f( 1 ) f( end ) ] );
            ffcbar( gcf, hAx( plotIdx ), 'tanh^{-1}(C)' );
            
        case 6
            hAx( plotIdx ) = subtightplot( nPlots, 1, plotIdx, opts{ : } );
            plotevents( plotIdx, evTs, yLimEmg );
            hold on
            plot( t2plot{ plotIdx }, datPlot{ plotIdx }, 'k' )
            ylim( yLimEmg )
            ylabel( emgLab )
            
        case 7
            hAx( plotIdx ) = subtightplot( nPlots, 1, plotIdx, opts{ : } );
            plotevents( plotIdx, evTs, yLimDlc );
            hold on
            col1 = getbodypartcolor( 'snout' );
            col2 = getbodypartcolor( 'hips' );
            plot( t2plot{ plotIdx }, datPlot{ plotIdx }( :, 1 ),...
                'Color', col1 )
            plot( t2plot{ plotIdx }, datPlot{ plotIdx }( :, 2 ),...
                'Color', col2 )
            ylim( yLimDlc )
            ylabel( dlcLab )
            
    end
    
    % Define colormap
    colormap magma
    
end

xlabel( sprintf( 'time (%s)', tUnits ) )

% Set properties
set( hAx,...
    'box', 'off' )

% link axes
linkaxes( hAx, 'x' )
linkaxes( hAx( [ 1 3 ] ), 'y' ) % link lfp's
linkaxes( hAx( [ 2 4 5 ] ), 'y' ) % link specs and coher
hLink = linkprop( hAx( [ 2 4 ] ), 'CLim' );

% Set frequency range to show in spectra an coher
if ismatrix( yLimsSpec )
    ylim( hAx( 2 ), yLimsSpec )
    
end


% set default color axes for spectrogram .
if strcmpi( specLims, 'auto' )
    cLims = round( prctile( pow2db( spec.S( : ) ), [ 5 99 ] ) );
    caxis( hAx( 2 ), cLims );
    
else
    caxis( hAx( 2 ), specLims );
    
end

% set default color axes for coherence
cLimsCoher = prctile( atanh( coher.C( : ) ), [ 5 99 ] );
caxis( hAx( 5 ), cLimsCoher );

% set other poperties
if strcmp( xLims, 'all' )
    axis tight
    
else
    xlim( xLims );
    
end
set( hAx, 'FontSize', 11 )

function plotevents( plotIdx, evTs, yLims )

% Plot events as lines if time-frequency, as patches otherwise.
if ~isempty( evTs )
    switch plotIdx
        case{ 2, 4, 5 }
            X = evTs * ones( 1, 2 );
            Y = yLims .* ones( length( evTs ), 1 );
            line( gca, X', Y',...
                'color', [ 0.5 0.5 0.5 ],...
                'Linewidth', 2 )
            
        otherwise
            for i = 1 : 2 : length( evTs )
                X = [ evTs( i ), evTs( i ), evTs( i + 1 ), evTs( i + 1 ) ];
                Y = [ yLims( 1 ), yLims( 2 ), yLims( 2 ), yLims( 1 ) ];
                patch( X, Y, [ 0.5 0.5 0.5 ],...
                    'FaceAlpha', 0.3,...
                    'EdgeColor', 'none' )
                
            end
            
    end

end

