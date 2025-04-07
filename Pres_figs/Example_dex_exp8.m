%% Load Dex experiment and get data
ccc
path2load = "E:\Dropbox (Personal)\Projects\034_DARPA_ABC\Results\M101";
f2load = "2024-08-07_M101_01";
matObj = matfile( fullfile( path2load, f2load ), 'Writable', false );

% Get Spectrogram, EMG, and EEG traces
% exp 8 (10 ug/kg dex injection @ ~3150 seconds)
% baseline (awake): 2560 to 2390 seconds (2365 - 2375)
% dex stuff: 5015 to 5045 seconds (5020 - 5030)
%
% exp 1
% baseline (NREM): 3900 to 3930 seconds (3915 - 3925)

tSpec = matObj.ephysData.spec.t;
f = matObj.ephysData.spec.f;

idxSpec = tSpec >= 2000 & tSpec <= 8000;
fIdx = f <= 40;
f2plot = f( fIdx );
t2plot = tSpec( idxSpec );
t2plot = ( t2plot - t2plot( 1 ) ) / 60;
specL = squeeze( ephysData.spec.S( idxSpec, fIdx, 1 ) );
specR = squeeze( ephysData.spec.S( idxSpec, fIdx, 2 ) );

tEmg = ephysData.emg.tSmooth;
idxEmg = tEmg >= 2000 & tEmg <= 8000;
tEmg2plot = tEmg( idxEmg );
tEmg2plot = ( tEmg2plot - tEmg2plot( 1 ) ) / 60;
emg = ephysData.emg.smooth( idxEmg );


ts = ephysData.eeg.ts( :, 1 );

idxBase = ts >= 2365 & ts <= 2375;
eegBase = ephysData.eeg.filt( idxBase, : );
tsBase = ts( idxBase );

idxDex = ts >= 5020 & ts <= 5030;
eegDex = ephysData.eeg.filt( idxDex, : );
tsDex = ts( idxDex );

%% Load sleep experiment
clear ephysData
f2load = "2024-04-02_M101_baseline";
load( fullfile( path2load, f2load ) );

idxSleep = ts >= 3915 & ts <= 3925;
eegSleep = ephysData.eeg.filt( idxSleep, : );
tsSleep = ts( idxSleep );

%% Compute spectra for all traces
Fs = 2713;
params = struct(...
    'tapers', [ 3 5 ],...
    'Fs', Fs,...
    'fpass', [ 0.5 40 ],...
    'pad', 2,...
    'trialave', 1 );
eegDexPad = [ eegDex; [ 0 0 ] ];

eegL = [ eegBase( :, 1 ) eegDexPad( :, 1 ) eegSleep( :, 1 ) ];
eegR = [ eegBase( :, 2 ) eegDexPad( :, 2 ) eegSleep( :, 2 ) ];
for i = 1 : 3
    segL = makesegments( eegL( :, i ), Fs, [ 2 1.9 ] );
    [ SL{ i }, f ] = mtspectrumc( segL, params );

    segR = makesegments( eegR( :, i ), Fs, [ 2 1.9 ] );
    [ SR{ i }, f ] = mtspectrumc( segR, params );

end


% [ Sr, f ] = mtspectrumc( eegR, params );

%% make figures
% Spec figure
figure
colormap( magma )
hAx( 1 ) = subplot( 3, 1, 1 );
imagesc( t2plot, f2plot, pow2db( specL' ) )
axis xy
box off
caxis( [ 0 30 ] )
ffcbar( gcf, gca, 'Power (dB)' );
title( 'EEG', 'Position', [ 4 41 ] )
ylabel( 'Freq. (Hz)' )
hAx( 1 ).XTickLabel = [];

hAx( 2 ) = subplot( 3, 1, 2 );
imagesc( t2plot, f2plot, pow2db( specR' ) )
axis xy
box off
caxis( [ 0 30 ] )
ffcbar( gcf, gca, 'Power (dB)' );
title( 'EEG', 'Position', [ 4 41 ] )
ylabel( 'Freq. (Hz)' )
hAx( 2 ).XTickLabel = [];

hAx( 3 ) = subplot( 3, 1, 3 );
plot( tEmg2plot, emg, 'k' );
box off
axis tight
title( 'EMG', 'Position', [ 4 1.04 ] )
ylabel( 'Muscle Act. (a.u.)' )
xlabel( 'Time (min)' )

set( hAx, 'FontSize', 12, 'TickDir', 'out' )
set( gcf, 'Position', [ 0.3664    0.3208    0.3292    0.4338 ] )

%% EEG example figure
figure

cols = brewermap( 6, 'Set1' );
offset = 400;
hAx( 1 ) = subplot( 3, 1, 1 );
plot( tsBase, eegBase( :, 1 ), 'Color', cols( 1, : ) )
hold on
plot( tsBase, eegBase( :, 2 ) - offset, 'Color', cols( 2, : ) )
ylim( [ -850 400 ] )
box off
hold off
title( 'Baseline' )

hAx( 2 ) = subplot( 3, 1, 2 );
plot( tsDex, eegDex( :, 1 ), 'Color', cols( 1, : ) )
hold on
plot( tsDex, eegDex( :, 2 ) - offset, 'Color', cols( 2, : ) )
ylim( [ -850 400 ] )
box off
hold off
title( 'Dex (10 \mug/kg)' )

hAx( 3 ) = subplot( 3, 1, 3 );
plot( tsSleep, eegSleep( :, 1 ), 'Color', cols( 1, : ) )
hold on
plot( tsSleep, eegSleep( :, 2 ) - offset, 'Color', cols( 2, : ) )
ylim( [ -850 400 ] )
box off
hold off
title( 'Non-REM sleep' )
set( hAx, 'FontSize', 12, 'TickDir', 'out' )

%% Plot spectra
figure

for i = 1 : 3
    subplot( 2, 1, 1 )
    plot( f, pow2db( SL{ i } ) )
    hold on

    subplot( 2, 1, 2 )
    plot( f, pow2db( SR{ i } ) )
    hold on

end
legend( 'base', 'dex', 'sleep' )
