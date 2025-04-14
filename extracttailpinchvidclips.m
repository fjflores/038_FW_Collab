%% Extract tail pinch video clips from FW collab experiment videos.
%% Gather relevant stuff.

ccc

% Get dirs.
root = getrootdir;
datDir = fullfile( root, 'Data' );
resDir = fullfile( root, 'Results' );

% Load FW exp details table and get experiments with tail pinches.
fwTabPath = fullfile( resDir, 'FW_collab_exp_details.xlsx' );
opts = detectImportOptions( fwTabPath );
tailPinchCols = { 'tail_pinch_5_ts',...
    'tail_pinch_30_ts', 'tail_pinch_35_ts',...
    'tail_pinch_60_ts', 'tail_pinch_120_ts' };
opts = setvartype( opts, tailPinchCols, 'double' );
fwTab = readtable( fwTabPath, opts );
expIdcs = any( ~isnan( table2array( fwTab( :, tailPinchCols ) ) ), 2 );
expList = fwTab.exp_id( expIdcs );

% Set directory to save video clips to.
dbFolder = erase( root, '034_DARPA_ABC\' );
saveDir = fullfile( dbFolder, 'FW_tail_pinch_vids' );

% Load existing key and score sheet so as not to overwrite.
if exist( fullfile( resDir, 'FW_tail_pinch_key.csv' ) )
    renameKeyOG = readtable(...
        fullfile( resDir, 'FW_tail_pinch_key.csv' ),...
        'Delimiter', ',' );
    scoresPDOG = readtable(...
        fullfile( saveDir, 'scores_PD.xlsx' ) );
    scoresVarNames = scoresPDOG.Properties.VariableNames;

else
    fprintf( 'FW_tail_pinch_key.csv does not exist yet.\n' )

end


%% Extract and save clips.

nExp = length( expList );
fprintf( 'Extracting video clips from %i experiment(s)...\n', nExp )
skipCnt = 0;
saveCnt = 0;
for expIdx = 1 : nExp

    expID = expList( expIdx );

    % Get file paths.
    metDat = getmetadata( expID );
    mouse = metDat.subject;
    nlynxDir = metDat.nlynxDir;
    bonsaiSuff = metDat.bonsaiSuff;
    mDatDir = fullfile( datDir, mouse );
    vNameSide = strcat( 'sideview_vid_', bonsaiSuff, '.avi' );
    vNameTop = strcat( 'topview_vid_', bonsaiSuff, '.avi' );
    vidPathSide = fullfile( mDatDir, vNameSide );
    vidPathTop = fullfile( mDatDir, vNameTop );

    % Check if video pair is already in 'FW_tail_pinch_key'.    
    if any( ~cellfun( @isempty,...
            strfind( renameKeyOG.expInfo, bonsaiSuff ) ) )
        skipCnt = skipCnt + 1;
        continue
    end
    clear bonsaiSuff

    % Get tail pinch timestamps (seconds, in ephys timestamps).
    tailPinchTs = fwTab{ fwTab.exp_id == expID, tailPinchCols };
    tailPinchTs = tailPinchTs( ~isnan( tailPinchTs ) );
    evTsTmp = [ tailPinchTs' [ tailPinchTs' + 30 ] ];

    % Calculate difference between ephys recording start time and video
    % recording start time (to nearest second).
    ephysLog = fileread(...
        fullfile( mDatDir, nlynxDir, 'CheetahLogFile.txt' ) );
    ephysRecTs = regexp( ephysLog,...
        [ '(\d{2})\:(\d{2})\:(\d{2}\.\d{3})',...
        '(?: - )\d+(?: - AcquisitionControl::StartRecording)' ],...
        'tokens' );
    ephysRecTs = str2double( ephysRecTs{ : } );
    ephRec = datetime( 1, 1, 1,...
        ephysRecTs( 1 ), ephysRecTs( 2 ), round( ephysRecTs( 3 ) ) );
    vidLog = fullfile( mDatDir,...
        strcat( 'vid_rec_ts_', metDat.bonsaiSuff, '.csv' ) );
    vidLog = readtable( vidLog, 'ReadVariableNames', false );
    vidRecTs = regexp( vidLog{ 1, 2 }{ 1 },...
        'T(\d{2})\:(\d{2})\:(\d{2}\.\d{3})', 'tokens');
    vidRecTs = str2double( vidRecTs{ : } );
    vidRec = datetime( 1, 1, 1,...
        vidRecTs( 1 ), vidRecTs( 2 ), round( vidRecTs( 3 ) ) );
    difRec = between( ephRec, vidRec );
    difRec = time( difRec );
    difRec = round( seconds( difRec ) );

    % Extract tail pinch video clips.
    evTs = evTsTmp - difRec;
    pad = [ 10 40 ];
    extractvidclip( vidPathSide, evTs,...
        'Pad', pad, 'EvMsg', 'tailpinch',...
        'SaveDir', saveDir, 'SaveFlag', true );
    extractvidclip( vidPathTop, evTs,...
        'Pad', pad, 'EvMsg', 'tailpinch',...
        'SaveDir', saveDir, 'SaveFlag', true );
    saveCnt = saveCnt + 1;

end

fprintf( [ 'Extracted video clips from %i experiment(s) and ',...
    'skipped %i experiment(s).\n' ], saveCnt, skipCnt )


%% Anonymize and shuffle tail pinch video clips for blind scoring.

% Only get video pairs that need to be renamed.
vidListTmp = dir( fullfile( saveDir, '*.avi' ) );
vidList = vidListTmp( 3 : end );
vids = sort( { vidList.name } );
vids = vids';
vids2RenameTmp = regexp( vids,...
    '.*_\d{4}-\d{2}-\d{2}T\d{2}_\d{2}_\d{2}.*\.avi', 'match' );
vids2Rename = vids( ~cellfun( @isempty, vids2RenameTmp ) );
nPinches = length( vids2Rename ) / 2;
vids2Rename = reshape( vids2Rename, [ nPinches 2 ] );
vids2Ignore = vids( cellfun( @isempty, vids2RenameTmp ) );
vids2IgnoreIDs = str2double( string(...
    regexp( vids2Ignore, '(\d{3})_', 'tokens' ) ) );
randIDOptions = randperm( 999, numel( vids ) );
randIDOptions = randIDOptions(...
    ~ismember( randIDOptions, vids2IgnoreIDs ) );

if nPinches == 0
    fprintf( 'No video pairs to rename.\n' )
elseif numel( vids2Rename ) < numel( vids )
    fprintf( [ 'Only renaming the %i pairs of videos that need ',...
        'to be renamed...\n' ], nPinches )
else
    fprintf( 'Renaming all %i pairs of videos...\n', nPinches )
end

% Assign each video pair to random ID.
randID = zeros( nPinches, 1 );
randIDStr = strings( nPinches, 1 );
expInfo = strings( nPinches, 1 );
ogNameSide = strings( nPinches, 1 );
ogNameTop = strings( nPinches, 1 );
newNameSide = strings( nPinches, 1 );
newNameTop = strings( nPinches, 1 );
for pinchIdx = 1 : nPinches
    randID( pinchIdx ) = randIDOptions( pinchIdx ); % Random 3-digit ID.
    randIDStr( pinchIdx ) = sprintf( '%03d', randID( pinchIdx ) );
    expInfo( pinchIdx ) = string( regexp( vids2Rename{ pinchIdx, 1 },...
        '.*_(\d{4}-\d{2}-\d{2}T\d{2}_\d{2}_\d{2}.*)\.avi', 'tokens' ) );
    ogNameSide( pinchIdx ) = string( vids2Rename{ pinchIdx, 1 } ); 
    ogNameTop( pinchIdx ) = string( vids2Rename{ pinchIdx, 2 } );
    newNameSide( pinchIdx ) = strcat( randIDStr( pinchIdx ), '_side.avi' );
    newNameTop( pinchIdx ) = strcat( randIDStr( pinchIdx ), '_top.avi' );

    % Rename files.
    movefile( fullfile( saveDir, ogNameSide( pinchIdx ) ),...
        fullfile( saveDir, newNameSide( pinchIdx ) ) );
    movefile( fullfile( saveDir, ogNameTop( pinchIdx ) ),...
        fullfile( saveDir, newNameTop( pinchIdx ) ) );

end

% Save record of renamed files.
renameKeyNew = table( randID, randIDStr, expInfo,...
    ogNameSide, ogNameTop, newNameSide, newNameTop );
scoresPDNew = table( randID, nan( length( randID ), 1 ), strings( length( randID ), 1 ),...
    'VariableNames', scoresVarNames );

if exist( 'renameKeyOG', 'var' )
    renameKey = [ renameKeyOG; renameKeyNew ];
    scoresPD = [ scoresPDOG; scoresPDNew ];
    scoresPD = sortrows( scoresPD, 'tail_pinch_id' );
else
    renameKey = renameKeyNew;
end

writetable( renameKey,...
    fullfile( resDir, 'FW_tail_pinch_key.csv' ) )
writetable( scoresPD,...
    fullfile( saveDir, 'scores_PD.xlsx' ) )
fprintf( 'Saved updated ''FW_tail_pinch_key'' and ''scores''.\n')
clear randID


%% Match scores to tail pinches with relevant exp info.

% 1) Run first section of this script.

% 2) Run this section.

clear expID mID bonsaiSuff randID
cnt = 1;
for expIdx = 1 : length( expList )
    thisExpID = expList( expIdx );
    thisExp = fwTab( fwTab.exp_id == thisExpID, : );
    metDat = getmetadata( thisExpID );
    thisBonsaiSuff = metDat.bonsaiSuff;
    
    tpIdcs = ~isnan( table2array( thisExp( :, tailPinchCols ) ) );
    tps = find( tpIdcs );

    for tpIdx = 1 : length( tps )
        tpNum( cnt, 1 ) = tpIdx;
        tpCol = tailPinchCols( tps( tpIdx ) );
        tpTs( cnt, 1 ) = table2array( thisExp( :, tpCol ) );
        approxMinTmp = regexp( tpCol, '_(\d+)_ts', 'tokens' );
        approxMin( cnt, 1 ) = str2double( approxMinTmp{ 1 }{ 1 } );
        clear approxMinTmp

        % Get experiment-level info.
        expID( cnt, 1 ) = thisExpID;
        mID( cnt, 1 ) = thisExp.mouse_id;
        bonsaiSuff{ cnt, 1 } = thisBonsaiSuff;
        dexDose( cnt, 1 ) = thisExp.dex_dose_ug_per_kg;
        ketDose( cnt, 1 ) = thisExp.ket_dose_mg_per_kg;
        vasoDose( cnt, 1 ) = thisExp.vaso_dose_ug_per_kg;
        pdDose( cnt, 1 ) = thisExp.pd_dose_mg_per_kg;

        % Match tail pinch to key (FW_tail_pinch_key.csv).
        thisExpIdx = strcmp( renameKeyOG.expInfo,...
            sprintf( '%s_tailpinch%i', thisBonsaiSuff, tpIdx ) );
        thisRandID = renameKeyOG.randID( thisExpIdx );
        randID( cnt, 1 ) = thisRandID;

        % Match tail pinch random ID to score.
        thisRandIDIdx = scoresPDOG.tail_pinch_id == thisRandID;
        scorePD( cnt, 1 ) = scoresPDOG.score_PD( thisRandIDIdx );

        cnt = cnt + 1;

    end

end

tpTab = table( expID, mID, bonsaiSuff,...
    dexDose, ketDose, vasoDose, pdDose,...
    tpNum, approxMin, tpTs, randID, scorePD );

writetable( tpTab,...
    fullfile( resDir, 'FW_tail_pinch_table.csv') )
fprintf( 'Saved updated ''FW_tail_pinch_table''.\n' )


%% Plot tail pinch scores.

ccc

% Get dirs.
root = getrootdir;
datDir = fullfile( root, 'Data' );
resDir = fullfile( root, 'Results' );

tpTab = readtable( fullfile( resDir, 'FW_tail_pinch_table.csv') );


expList = unique( tpTab.expID );

dexLoCol = [ 103 169 207 ] / 255;
dexHiCol = [ 33 102 172 ] / 255;
ketLoCol = [ 239 138 98 ] / 255;
ketHiCol = [ 178 24 43 ] / 255;
comboCol = [ 77 77 77 ] / 255;

pdDoses = [ 0 0.5 1 ];
dexDoses = [ 0 1 2 ];
ketDoses = [ 0 3 ];
tpMins = [ 5 30 60 120 ];

expTypeCnt = 1;
for pdDoseIdx = 1 : length( pdDoses )
    thisPdDose = pdDoses( pdDoseIdx );
    if thisPdDose == 0
        thisVasoDose = 0;
    else
        thisVasoDose = 10; % So far have only tested 10 ug/kg vaso.
    end
    for dexDoseIdx = 1 : length( dexDoses )
        thisDexDose = dexDoses( dexDoseIdx );
        for ketDoseIdx = 1 : length( ketDoses )
            thisKetDose = ketDoses( ketDoseIdx );
            expType{ expTypeCnt, 1 } = sprintf(...
                '%i %cg/kg vaso + %.1f mg/kg PD + %.1f %cg/kg dex + %.1f mg/kg ket',...
                thisVasoDose, 956, thisPdDose, thisDexDose, 956, thisKetDose );
            expTypeDoses( expTypeCnt, : ) = [ thisVasoDose thisPdDose thisDexDose thisKetDose ];
            tpMinCnt = 1;
            for tpMinIdx = 1 : length( tpMins )
                thisTpMin = tpMins( tpMinIdx );
                avgscoresPD( expTypeCnt, tpMinCnt ) = mean( tpTab.scorePD(...
                    tpTab.pdDose == thisPdDose &...
                    tpTab.dexDose == thisDexDose &...
                    tpTab.ketDose == thisKetDose &...
                    tpTab.approxMin == thisTpMin ) );
                tpMinCnt = tpMinCnt + 1;

            end

            expTypeCnt = expTypeCnt + 1;

        end

    end

end

% Clean up avgScores.
rows2keep = any( ~isnan( avgscoresPD ), 2 );
avgscoresPD = avgscoresPD( rows2keep, : );
expTypeDoses = expTypeDoses( rows2keep, : );
expType = expType( rows2keep );


figure
hold on
% scatterjit( tpTab.approxMin, tpTab.scorePD,...
%     'filled', 'MarkerFaceAlpha', 0.5, 'Jit', 2.5 );
for expTypeIdx = 1 : length( expType )
    vasoDose = expTypeDoses( expTypeIdx, 1 );
    pdDose = expTypeDoses( expTypeIdx, 2 );
    dexDose = expTypeDoses( expTypeIdx, 3 );
    ketDose = expTypeDoses( expTypeIdx, 4 );
    
    if pdDose == 0.5
        lnWeight = 2;
        lnStyle = '-';
    elseif pdDose == 1
        lnWeight = 4;
        lnStyle = '-';
    elseif pdDose == 0
        lnWeight = 2;
        lnStyle = ':';
    end

    if dexDose == 0 && ketDose == 0
        lnCol = comboCol;
    elseif dexDose == 1 && ketDose == 0
        lnCol = dexLoCol;
    elseif dexDose == 2 && ketDose == 0
        lnCol = dexHiCol;
    elseif dexDose == 0 && ketDose == 3
        lnCol = ketLoCol;
    else
        warning( 'Something wrong :(' )
    end


    plot( tpMins, avgscoresPD( expTypeIdx, : ),...
        'LineWidth', lnWeight,...
        'LineStyle', lnStyle,...
        'Color', lnCol )
end

ylim( [ 0 4 ] )
legend( expType{ : } )


%% Compare IDB and PD scoring.
clear all

IDB = readtable( fullfile( getrootdir, 'Results', 'scores_IDB.xlsx' ) );
PD = readtable( fullfile( 'D:\Dropbox (Personal)\FW_tail_pinch_vids',...
    'scores_PD.xlsx' ) );
scores = table( IDB.tail_pinch_id, PD.score_PD, IDB.score_IDB,...
    'VariableNames', { 'tpID', 'PD', 'IDB' } );

scores = sortrows( scores, 'IDB' );
idcs = ~isnan( scores.PD );
figure
hold on
scatter( 1 : sum( idcs ), scores.PD( idcs ),...
    'r', 'filled', 'MarkerFaceAlpha', 0.4 )
scatter( 1 : sum( idcs ), scores.IDB( idcs ),...
    'b', 'filled', 'MarkerFaceAlpha', 0.4 )
ylim( [ 0 4 ] )
legend( {'PD', 'IDB' } )
xticks([])
ylabel( 'Score' )

difs = scores.PD - scores.IDB;
figure
histogram( difs, [ -0.55 : 0.1 : 0.55 ] )
title( 'PD score - IDB score' )



