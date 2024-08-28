function makespecfig( presDir )

path2load = fullfile( getrootdir, 'Pres', presDir, 'Assets' );
f2load = "FigData.mat";
data = load( fullfile( path2load, f2load ), 'emg', 'spec' );

%% make figures
% Spec figure
figure
colormap( magma )
hAx( 1 ) = subplot( 3, 1, 1 );
specL = data.spec.L;
f2plot = data.spec.f2plot;
t2plot = data.spec.t2plot;
imagesc( t2plot, f2plot, pow2db( specL' ) )
axis xy
box off
caxis( [ 0 30 ] )
ffcbar( gcf, gca, 'Power (dB)' );
title( 'EEG', 'Position', [ 4 41 ] )
ylabel( 'Freq. (Hz)' )
hAx( 1 ).XTickLabel = [];

hAx( 2 ) = subplot( 3, 1, 2 );
specR = data.spec.R;
imagesc( t2plot, f2plot, pow2db( specR' ) )
axis xy
box off
caxis( [ 0 30 ] )
ffcbar( gcf, gca, 'Power (dB)' );
title( 'EEG', 'Position', [ 4 41 ] )
ylabel( 'Freq. (Hz)' )
hAx( 2 ).XTickLabel = [];

hAx( 3 ) = subplot( 3, 1, 3 );
emg = data.emg.smooth;
t2plot = data.emg.t2plot;
plot( t2plot, emg, 'k' );
box off
axis tight
title( 'EMG', 'Position', [ 4 1.04 ] )
ylabel( 'Muscle Act. (a.u.)' )
xlabel( 'Time (min)' )

set( hAx, 'FontSize', 12, 'TickDir', 'out' )
set( gcf, 'Position', [ 0.3664    0.3208    0.3292    0.4338 ] )