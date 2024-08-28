function maketracefig( presDir )

path2load = fullfile( getrootdir, 'Pres', presDir, 'Assets' );
f2load = "FigData.mat";
data = load( fullfile( path2load, f2load ), 'eeg' );

%% EEG example figure
figure

cols = brewermap( 6, 'Set1' );
offset = 400;
hAx( 1 ) = subplot( 3, 1, 1 );
eegBaseL = data.eeg.base.L;
eegBaseR = data.eeg.base.R;
t2plot = data.eeg.t2plot.base;
plot( t2plot, eegBaseL, 'Color', cols( 1, : ) )
hold on
plot( t2plot, eegBaseR - offset, 'Color', cols( 2, : ) )
ylim( [ -850 400 ] )
box off
hold off
ylabel( "Amp. (\muV)" )
title( 'Baseline' )

hAx( 2 ) = subplot( 3, 1, 2 );
eegDexL = data.eeg.dex.L;
eegDexR = data.eeg.dex.R;
t2plot = data.eeg.t2plot.dex;
plot( t2plot, eegDexL, 'Color', cols( 1, : ) )
hold on
plot( t2plot, eegDexR - offset, 'Color', cols( 2, : ) )
ylim( [ -850 400 ] )
box off
hold off
title( 'Dex (10 \mug/kg)' )

hAx( 3 ) = subplot( 3, 1, 3 );
eegSleepL = data.eeg.sleep.L;
eegSleepR = data.eeg.sleep.R;
t2plot = data.eeg.t2plot.sleep;
plot( t2plot, eegSleepL, 'Color', cols( 1, : ) )
hold on
plot( t2plot, eegSleepR - offset, 'Color', cols( 2, : ) )
ylim( [ -850 400 ] )
box off
hold off
title( 'Non-REM sleep' )

set( hAx,...
    'FontSize', 12,...
    'TickDir', 'out',...
    'XTickLabel', [],...
    'YTick', [ -400 0 400 ] )