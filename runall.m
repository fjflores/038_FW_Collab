%% Batch-process the ephys data.
ccc

% Define experiment of interest.
expList = [ 123 124 ];

% Set parameters.
specWin = [ 10 1 ];
params = struct(...
    'specWin', specWin,...
    'detWin', [ 2 1.8 ],...
    'tapers', [ 3 5 ],...
    'pad', 0,...
    'err', [ 2 0.05 ],...
    'fpass', [ 1 / specWin( 1 ) 100 ],...
    'filtEeg', [ 1 40 ],...
    'filtEmg', [ 200 700 ] );
smoothEmg = false;
overwrite = true;

% Read and save processed data.
% exps2proc = getexp2proc( expList ); % only includes to-analyze experiments
% batchprocephys( exps2proc, params, smoothEmg, overwrite )
batchprocephys( expList, params, smoothEmg, overwrite )


%% Plot entire experiment.
clear all
% close all
% clc

% Define experiment of interest.
expId = 124;

% expData = loadmixdata( expID );

figure( 'Name', sprintf( 'Exp. %i', expId ), 'WindowState', 'maximized' )
[ hAx, hLink ] = plotexp( expId,...
    'SetShowEeg', 'raw',...
    'SetAmpEeg', [ -700 700 ],...
    'SetFreqSpec', [ 0.5 100],...
    'SetCAxis', [ 0 40 ],...
    'SetShowEmg', 'raw',... % choose raw, filt, or smooth
    'MinOrSec', 'sec' ); 

% TEMPORARY: turn this chunk into an option within plotexp
metTab = readtable( fullfile( getrootdir, 'Results', 'abc_experiment_list.xlsm' ) );
tsTab = table2array( metTab( :, { 'drug_ts_offline', 'drug_ts_online',...
    'ati_ts_offline', 'ati_ts_online', 'drug_ts_inj', 'ati_ts_inj' } ) );
metDat = getmetadata( expId );

fwTab = readtable(...
    fullfile( getrootdir, 'Results', 'FW_collab_exp_details.xlsx' ) );

% xline( hAx( 1 ), tsTab( expId, 1 : 4 ), 'm', 'LineWidth', 2 )
% xline( hAx( 1 ), tsTab( expId, 5 : 6 ), 'g', 'LineWidth', 2 )
% xline( hAx( 3 ), tsTab( expId, 1 : 4 ), 'm', 'LineWidth', 2 )
% xline( hAx( 3 ), tsTab( expId, 5 : 6 ), 'g', 'LineWidth', 2 )
for i = 1 : 6
    xline( hAx( i ), tsTab( expId, 5 ), 'g', 'LineWidth', 2 )

    if metDat.FWCollab == 1
        xline( hAx( i ),...
            str2double( fwTab{ ( fwTab.exp_id == expId ), 10 : 12 } ),...
            'g', 'LineWidth', 1 ) % FW exps only
    end

end


%% Batch process and save DLC and video data.
close all
clear all
clc

addpath( ".\Vid_processing\" )

expList = 14; 

params = struct(...
    'pcutoff', 0.9,...
    'deltalim', 20,...
    'filterType', 'kalmanff',... % 'median' or 'kalmanFF'
    'filterOrder', 15,... % for median filt
    'dt', 0.5,... % for kalman filt
    'fps', 30 );
    
overwrite = false;

% expList = getexp2proc( expList ); % only includes to-analyze experiments
% Batch process DLC data AND batch align and save all video timestamps.
% batchprocdlc( expList, params, overwrite );
% batchvidts( expList, overwrite );

% OR Batch process DLC and align video ts all at once.
batchprocvid( expList, params, overwrite );

% rmpath( '.\Vid_processing\' )

%% Save the data for sleep scoring
ccc
warning off

mouseId = "M106";
savesleepdata( mouseId )

%% Batchprocess mice to get tidy data
ccc
addpath( ".\Dose_effect\" )

% mList = { "M101", "M102", "M103", "M105", "M106",...
%     "M107", "M108", "M109", "M111", "M112", "M113" };
mList = { "M111", "M112" };
csvFile = "abc_experiment_list.xlsm";
tLims = [ 600 4200 ];
saveFlag = true;  
warning off
batchtidydata( mList, csvFile, tLims, saveFlag )
warning on

%% Get spectral features over time
ccc
% addpath( ".\Pres_figs" )
addpath( ".\Dose_effect\" )

doses = [ 0 10 30 50 100 150 ];
tLims = [ -5 5 65 ];
% doses = [ 0 10 30 50 100 150 ];
% tLims = [ 55 5 65 ];
drug = "dex";
warning off
allFeats = savetimefeats( doses, tLims, drug );
warning on

root = getrootdir( );
save( fullfile( root, "Results\Dose_Effect", "Long_Feat_Table.mat" ),...
    "allFeats" )

%% Fit linear mixed-effects model to time features
ccc
addpath( ".\Pres_figs" )
addpath( ".\Dose_effect\" )
root = getrootdir( );
load( fullfile( root, "Results\Dose_Effect", "Long_Feat_Table.mat" ),...
    "allFeats" )

warning off
mdls = fitfeats( allFeats, 5 : 11 );
warning on

% save( fullfile( root, "Results\Dose_Effect", "Feature_fits.mat" ),...
%     "mdls" )

%% Add db power columns to timeFeats.
ccc
root = getrootdir( );
featsFile = fullfile( root, "Results\Dose_Effect", "Time_Ave_Feats.mat" );
load( featsFile, "timeFeats" )

for epIdx = 1 : length( timeFeats )
        timeFeats( epIdx ).featTab{ :, 'PdeltaDB' } = pow2db(...
            timeFeats( epIdx ).featTab{ :, 'Pdelta' } );
        timeFeats( epIdx ).featTab{ :, 'PspindleDB' } = pow2db(...
            timeFeats( epIdx ).featTab{ :, 'Pspindle' } );

end

save( featsFile, 'timeFeats', '-append' )
