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
tpTmp = regexp( opts.VariableNames, 'tail_pinch.*_ts', 'match' );
tailPinchCols = string( tpTmp( ~cellfun( @isempty, tpTmp ) ) );
opts = setvartype( opts, tailPinchCols, 'double' );
fwTab = readtable( fwTabPath, opts );
expIdcs = any( ~isnan( table2array( fwTab( :, tailPinchCols ) ) ), 2 );
expList = fwTab.exp_id( expIdcs );

% Set directory to save video clips to.
dbFolder = erase( root, '034_DARPA_ABC\' );
saveDir = fullfile( dbFolder, 'FW_tail_pinch_vids' );

% Load existing key and score sheets so as not to overwrite.
if exist( fullfile( resDir, 'FW_tail_pinch_key.csv' ) )
    renameKeyOG = readtable(...
        fullfile( resDir, 'FW_tail_pinch_key.csv' ),...
        'Delimiter', ',' );
    scoresPDOG = readtable(...
        fullfile( saveDir, 'scores_PD.xlsx' ) );
    scoresIDBOG = readtable(...
        fullfile( resDir, 'scores_IDB.xlsx' ) );
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

    % % Check if video pair is already in 'FW_tail_pinch_key'.    
    % if any( ~cellfun( @isempty,...
    %         strfind( renameKeyOG.expInfo, bonsaiSuff ) ) )
    %     skipCnt = skipCnt + 1;
    %     continue
    % end
    % clear bonsaiSuff

    % Get tail pinch timestamps (seconds, in ephys timestamps).
    tailPinchTs = fwTab{ fwTab.exp_id == expID, tailPinchCols };
    tailPinchTs = tailPinchTs( ~isnan( tailPinchTs ) );
    evTsTmp = [ tailPinchTs' [ tailPinchTs' + 30 ] ];

    % Calculate difference between ephys recording start time and video
    % recording start time (to nearest second).
    ephysLog = fileread(...
        fullfile( mDatDir, nlynxDir, 'CheetahLogFile.txt' ) );
    ephysRecTs = regexp( ephysLog,...
        [ '(\d{1,2})\:(\d{2})\:(\d{2}\.\d{3})',...
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

end

% Make record of files to rename and their codes.
renameKeyNew = table( randID, randIDStr, expInfo,...
    ogNameSide, ogNameTop, newNameSide, newNameTop );
scoresPDNew = table( randID, nan( length( randID ), 1 ),...
    strings( length( randID ), 1 ),...
    'VariableNames', scoresVarNames );
scoresIDBNew = table( randID, nan( length( randID ), 1 ),...
    strings( length( randID ), 1 ),...
    'VariableNames', scoresVarNames );

if exist( 'renameKeyOG', 'var' )
    renameKey = [ renameKeyOG; renameKeyNew ];
    scoresPD = [ scoresPDOG; scoresPDNew ];
    scoresPD = sortrows( scoresPD, 'tail_pinch_id' );
    scoresIDB = [ scoresIDBOG; scoresIDBNew ];
    scoresIDB = sortrows( scoresIDB, 'tail_pinch_id' );
else
    renameKey = renameKeyNew;
end

% Rename files.
clear pinchIdx
for pinchIdx = 1 : nPinches
    movefile( fullfile( saveDir, ogNameSide( pinchIdx ) ),...
        fullfile( saveDir, newNameSide( pinchIdx ) ) );
    movefile( fullfile( saveDir, ogNameTop( pinchIdx ) ),...
        fullfile( saveDir, newNameTop( pinchIdx ) ) );

end

% Save record of renamed files.
writetable( renameKey,...
    fullfile( resDir, 'FW_tail_pinch_key.csv' ) )
writetable( scoresPD,...
    fullfile( saveDir, 'scores_PD.xlsx' ) )
writetable( scoresIDB,...
    fullfile( resDir, 'scores_IDB.xlsx' ) )
fprintf( 'Saved updated ''FW_tail_pinch_key'' and ''scores''.\n')


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
        approxMinTmp = str2double( approxMinTmp{ 1 }{ 1 } );
        approxMin( cnt, 1 ) = approxMinTmp;
        pincher( cnt, 1 ) = thisExp.(...
            sprintf( 'tail_pincher_%i', approxMinTmp ) );
        clear approxMinTmp

        % Get experiment-level info.
        expID( cnt, 1 ) = thisExpID;
        mID( cnt, 1 ) = thisExp.mouse_id;
        bonsaiSuff{ cnt, 1 } = thisBonsaiSuff;
        floorTemp( cnt, 1 ) = thisExp.chamber_floor_approx_temp;
        dexDose1( cnt, 1 ) = thisExp.dex_dose_inj1;
        ketDose1( cnt, 1 ) = thisExp.ket_dose_inj1;
        vasoDose1( cnt, 1 ) = thisExp.vaso_dose_inj1;
        pdDose1( cnt, 1 ) = thisExp.pd_dose_inj1;
        dexDose2( cnt, 1 ) = thisExp.dex_dose_inj2;
        ketDose2( cnt, 1 ) = thisExp.ket_dose_inj2;
        vasoDose2( cnt, 1 ) = thisExp.vaso_dose_inj2;
        pdDose2( cnt, 1 ) = thisExp.pd_dose_inj2;
        inj1ts( cnt, 1 ) = thisExp.inj1_ts;
        inj2ts( cnt, 1 ) = thisExp.inj2_ts;

        % Match tail pinch to key (FW_tail_pinch_key.csv).
        thisExpIdx = strcmp( renameKeyOG.expInfo,...
            sprintf( '%s_tailpinch%i', thisBonsaiSuff, tpIdx ) );
        thisRandID = renameKeyOG.randID( thisExpIdx );
        randID( cnt, 1 ) = thisRandID;

        % Match tail pinch random ID to score (PD and IDB).
        thisRandIDIdx = scoresPDOG.tail_pinch_id == thisRandID;
        scorePD( cnt, 1 ) = scoresPDOG.score( thisRandIDIdx );
        scoreIDB( cnt, 1 ) = scoresIDBOG.score( thisRandIDIdx );

        cnt = cnt + 1;

    end

end

scoreDif = scorePD - scoreIDB;
scoreAvg = mean( [ scorePD scoreIDB ], 2, 'omitnan' );
if any( isnan( scorePD ) ) || any( isnan( scoreIDB ) )
    warning( 'At least one scorer is missing some scores.' )
else
    fprintf( 'Both scorers are caught up!\n' )
end

tpTab = table( expID, mID, bonsaiSuff, floorTemp,...
    dexDose1, ketDose1, vasoDose1, pdDose1,...
    dexDose2, ketDose2, vasoDose2, pdDose2,...
    inj1ts, inj2ts,...
    tpNum, approxMin, tpTs, pincher, randID,...
    scorePD, scoreIDB, scoreDif, scoreAvg );

writetable( tpTab,...
    fullfile( resDir, 'FW_tail_pinch_table.csv') )
fprintf( 'Saved updated ''FW_tail_pinch_table''.\n' )


%% Plot tail pinch scores. (WIP)

ccc

% Get dirs.
root = getrootdir;
datDir = fullfile( root, 'Data' );
resDir = fullfile( root, 'Results' );

tpTabPath = fullfile( resDir, 'FW_tail_pinch_table.csv');
opts = detectImportOptions( tpTabPath );
doseTmp = regexp( opts.VariableNames, '.*Dose.*', 'match' );
doseCols = string( doseTmp( ~cellfun( @isempty, doseTmp ) ) );
tsTmp = regexp( opts.VariableNames, '.*ts.*', 'match', 'ignorecase' );
tsCols = string( tsTmp( ~cellfun( @isempty, tsTmp ) ) );
opts = setvartype( opts, [ doseCols, tsCols ], 'double' );
tpTab = readtable( tpTabPath, opts );
tpTab.approxMinCode = ones( height( tpTab ), 1 );
tpTab.approxMinCode( tpTab.approxMin == 30 ) = 2;
tpTab.approxMinCode( tpTab.approxMin == 60 ) = 3;
tpTab.approxMinCode( tpTab.approxMin == 120 ) = 4;

dexLoCol = [ 103 169 207 ] / 255;
dexHiCol = [ 33 102 172 ] / 255;
ketLoCol = [ 239 138 98 ] / 255;
ketHiCol = [ 178 24 43 ] / 255;
comboLoCol = [ 77 77 77 ] / 255;
comboHiCol = [ 0 0 0 ] / 255;

% Get exps of interest.
% So far, all vaso doses = 10 ug/kg.
pdDoses = [ 0.5 ];
dexDoses = [ 0 1 2 ];
ketDoses = [ 0 3 ];
% dexDoses = 0;
% ketDoses = 0;
tpMins2exclude = [ 0 35 ]; % exclude baseline tail pinches
% exp2exclude = [ 129 138 143 ]; % exclude delayed ket exp for now
exp2exclude = [];

pdIdcs = ismember( tpTab.pdDose1, pdDoses ) | ismember( tpTab.pdDose2, pdDoses );
dexIdcs = ismember( tpTab.dexDose1, dexDoses ) | ismember( tpTab.dexDose2, dexDoses );
ketIdcs = ismember( tpTab.ketDose1, ketDoses ) | ismember( tpTab.ketDose2, ketDoses );
minIdcs = ~ismember( tpTab.approxMin, tpMins2exclude );
expIdcs = ~ismember( tpTab.expID, exp2exclude );
expOIIdcs = all( [ pdIdcs dexIdcs ketIdcs minIdcs expIdcs ], 2 );

subTpTab = tpTab( expOIIdcs, : );
expList = unique( subTpTab.expID );
doseTab = subTpTab( :, doseCols );
doseTabTmp = table2array( doseTab );
for rowIdx = 1 : height( doseTab )
    doseTabTmp( rowIdx, isnan( doseTabTmp( rowIdx, : ) ) ) = -99;
end
expTypes = unique( doseTabTmp, 'rows' );
nExpTypes = height( expTypes );
offsets = linspace( -0.15, 0.15, nExpTypes );

figure
hold on
for expIdx = 1 : length( expList )
    thisExp = expList( expIdx );
    thisExpTab = subTpTab( subTpTab.expID == thisExp, : );

    thisCol = comboLoCol; % default = lo combo
    offset = offsets( 1 );
    
    if thisExpTab.pdDose1( 1 ) == 1        
            thisCol = comboHiCol;
    end

    if thisExpTab.dexDose1( 1 ) == 1
            thisCol = dexLoCol;
            offset = offsets( 2 );
    elseif thisExpTab.dexDose1( 1 ) == 2
            thisCol = dexHiCol;
            offset = offsets( 3 );
    end

    if thisExpTab.ketDose2( 1 ) == 3
        thisCol = ketHiCol; % ONLY SOME ARE KET
        offset = offsets( 5 );
    elseif thisExpTab.ketDose1( 1 ) == 3
        thisCol = ketLoCol;
        offset = offsets( 4 );
    end

    hAx( expIdx ) = scatterjit( thisExpTab.approxMinCode + offset,...
        thisExpTab.scoreAvg,...
        40, 'filled', 'MarkerFaceColor', thisCol,...
        'MarkerFaceAlpha', 0.7, 'Jit', [ 0.04 0.05 ], 'Axis', 'xy' );

end

% xlim( [ -5 130 ] )
xlim( [ 0.4 4.6 ] )
ylim( [ 0.2 3.8 ] )
% xticks( [ 0 5 30 35 60 120 ] )
xticks( [ 1 : 1 : 4 ] )
xticklabels( [ 5 30 60 120 ] )
yticks( [ 1 : 1 : 4 ] )
xticklabels( [ 5 30 60 120 ] )
xlabel( 'Time after injection (min)' )
ylabel( 'Average tail pinch score' )
legend( hAx( [ 3 1 2 7 8 ] ),... % MAKE THIS BETTER
    { 'Combo',...
    sprintf( '+ 1 %cg/kg Dex', 956 ),...
    sprintf( '+ 2 %cg/kg Dex', 956 ),...
    '+ 3 mg/kg Ket @ t = 0',...
    '+ 3 mg/kg Ket @ t = 30' } )


%% Directly compare a few experiments.

exps2compare = [ 100 126 129 99 135 138 125 137 143 142 148 154 ];
cols = [ comboLoCol; ketLoCol; ketHiCol; comboLoCol; ketLoCol; ketHiCol; comboLoCol; ketLoCol; ketHiCol; comboLoCol; ketLoCol; ketHiCol ];
offset = [ -0.5 0 0.5 -0.5 0 0.5 -0.5 0 0.5 -0.5 0 0.5 ] * 3;

% exps2compare = [ 94 100 99 101 125 142 ];
% cols = [ dexHiCol; dexLoCol; dexLoCol; dexHiCol; dexLoCol; dexLoCol ];
% offset = [ 0.25 -0.25 -0.25 0.25 -0.25 -0.25 ] * 5;
% exps2compare = unique( tpTab.expID );
figure
hold on
clear expIdx thisExp thisExpTab expLabs
for expIdx = 1 : length( exps2compare )
    thisExp = exps2compare( expIdx );
    % expLabs{ expIdx } = sprintf( 'Exp %i', thisExp );
    hAx( expIdx ) = scatterjit( tpTab.approxMin( tpTab.expID == thisExp & tpTab.approxMin ~= 0 ) + offset( expIdx ),...
        tpTab.scoreAvg( tpTab.expID == thisExp & tpTab.approxMin ~= 0 ),...
        'filled', 'MarkerFaceAlpha', 0.7, 'MarkerFaceColor', cols( expIdx, : ),...
        'Jit', [ 0.5 0.04 ], 'Axis', 'xy' );

end

xlim( [ -5 130 ] )
ylim( [ 0.2 3.8 ] )
yticks( [ 1 : 1 : 4 ] )
xlabel( 'Time after first injection (min)' )
ylabel( 'Average tail pinch score' )
% legend( hAx( 1 : 3 ), { 'Combo', '+ 3 mg/kg Ket @ t = 0', '+ 3 mg/kg Ket @ t = 30' })
legend( hAx( 1 : 2 ), { sprintf( '10 %cg/kg vaso + 1 mg/kg PD', 956 ),...
    sprintf( '10 %cg/kg vaso + 0.5 mg/kg PD', 956 ) } )

% expTypeCnt = 1;
% for pdDoseIdx = 1 : length( pdDoses )
%     thisPdDose = pdDoses( pdDoseIdx );
%     if thisPdDose == 0
%         thisVasoDose = 0;
%     else
%         thisVasoDose = 10; % So far have only tested 10 ug/kg vaso.
%     end
%     for dexDoseIdx = 1 : length( dexDoses )
%         thisDexDose = dexDoses( dexDoseIdx );
%         for ketDoseIdx = 1 : length( ketDoses )
%             thisKetDose = ketDoses( ketDoseIdx );
%             expType{ expTypeCnt, 1 } = sprintf(...
%                 '%i %cg/kg vaso + %.1f mg/kg PD + %.1f %cg/kg dex + %.1f mg/kg ket',...
%                 thisVasoDose, 956, thisPdDose, thisDexDose, 956, thisKetDose );
%             expTypeDoses( expTypeCnt, : ) = [ thisVasoDose thisPdDose thisDexDose thisKetDose ];
%             tpMinCnt = 1;
%             for tpMinIdx = 1 : length( tpMins )
%                 thisTpMin = tpMins( tpMinIdx );
%                 avgScores( expTypeCnt, tpMinCnt ) = mean( tpTab.scoreAvg(...
%                     tpTab.pdDose == thisPdDose &...
%                     tpTab.dexDose == thisDexDose &...
%                     tpTab.ketDose == thisKetDose &...
%                     tpTab.approxMin == thisTpMin ) );
%                 tpMinCnt = tpMinCnt + 1;
% 
%             end
% 
%             expTypeCnt = expTypeCnt + 1;
% 
%         end
% 
%     end
% 
% end
% 
% % Clean up avgScores.
% rows2keep = any( ~isnan( avgScores ), 2 );
% avgScores = avgScores( rows2keep, : );
% expTypeDoses = expTypeDoses( rows2keep, : );
% expType = expType( rows2keep );
% 
% 
% figure
% hold on
% % scatterjit( tpTab.approxMin, tpTab.scorePD,...
% %     'filled', 'MarkerFaceAlpha', 0.5, 'Jit', 2.5 );
% for expTypeIdx = 1 : length( expType )
%     vasoDose = expTypeDoses( expTypeIdx, 1 );
%     pdDose = expTypeDoses( expTypeIdx, 2 );
%     dexDose = expTypeDoses( expTypeIdx, 3 );
%     ketDose = expTypeDoses( expTypeIdx, 4 );
% 
%     if pdDose == 0.5
%         lnWeight = 2;
%         lnStyle = '-';
%     elseif pdDose == 1
%         lnWeight = 4;
%         lnStyle = '-';
%     elseif pdDose == 0
%         lnWeight = 2;
%         lnStyle = ':';
%     end
% 
%     if dexDose == 0 && ketDose == 0
%         lnCol = comboCol;
%     elseif dexDose == 1 && ketDose == 0
%         lnCol = dexLoCol;
%     elseif dexDose == 2 && ketDose == 0
%         lnCol = dexHiCol;
%     elseif dexDose == 0 && ketDose == 3
%         lnCol = ketLoCol;
%     else
%         warning( 'Something wrong :(' )
%     end
% 
% 
%     plot( tpMins, avgScores( expTypeIdx, : ),...
%         'LineWidth', lnWeight,...
%         'LineStyle', lnStyle,...
%         'Color', lnCol )
% end
% 
% ylim( [ 0 4 ] )
% legend( expType{ : } )


%% Plot tail pinch scores for combo only.

ccc

% Get dirs.
root = getrootdir;
datDir = fullfile( root, 'Data' );
resDir = fullfile( root, 'Results' );

tpTabPath = fullfile( resDir, 'FW_tail_pinch_table.csv');
opts = detectImportOptions( tpTabPath );
doseTmp = regexp( opts.VariableNames, '.*Dose.*', 'match' );
doseCols = string( doseTmp( ~cellfun( @isempty, doseTmp ) ) );
tsTmp = regexp( opts.VariableNames, '.*ts.*', 'match', 'ignorecase' );
tsCols = string( tsTmp( ~cellfun( @isempty, tsTmp ) ) );
opts = setvartype( opts, [ doseCols, tsCols ], 'double' );
tpTab = readtable( tpTabPath, opts );
tpTab.approxMinCode = ones( height( tpTab ), 1 );
tpTab.approxMinCode( tpTab.approxMin == 30 ) = 2;
tpTab.approxMinCode( tpTab.approxMin == 60 ) = 3;
tpTab.approxMinCode( tpTab.approxMin == 120 ) = 4;

comboLoCol = [ 103 169 207 ] / 255;
comboHiCol = [ 33 102 172 ] / 255;
comboLoHeatCol = [ 239 138 98 ] / 255;
comboHiHeatCol = [ 178 24 43 ] / 255;

% Get exps of interest.
% So far, all vaso doses = 10 ug/kg.
pdDoses = [ 0.5 1 ];
dexDoses = 0;
ketDoses = 0;
floorTemps = [ 20 31 ];
tpMins2exclude = [ 0 35 ]; % exclude baseline tail pinches
exp2exclude = [ 129 138 143 154 ]; % exclude delayed ket bc ketIdcs not working properly 

pdIdcs = ismember( tpTab.pdDose1, pdDoses ) | ismember( tpTab.pdDose2, pdDoses );
dexIdcs = ismember( tpTab.dexDose1, dexDoses ) | ismember( tpTab.dexDose2, dexDoses );
ketIdcs = ismember( tpTab.ketDose1, ketDoses ) | ismember( tpTab.ketDose2, ketDoses ); % MAKES THIS ACTUALLY WORK
tempIdcs = ismember( tpTab.floorTemp, floorTemps );
minIdcs = ~ismember( tpTab.approxMin, tpMins2exclude );
expIdcs = ~ismember( tpTab.expID, exp2exclude );
expOIIdcs = all( [ pdIdcs dexIdcs ketIdcs tempIdcs minIdcs expIdcs ], 2 );

subTpTab = tpTab( expOIIdcs, : );
expList = unique( subTpTab.expID );
condTab = subTpTab( :, [ doseCols "floorTemp" ] ); % unique exp conditions
condTabTmp = table2array( condTab );
for rowIdx = 1 : height( condTab )
    condTabTmp( rowIdx, isnan( condTabTmp( rowIdx, : ) ) ) = -99;
end
expTypes = unique( condTabTmp, 'rows' );
nExpTypes = height( expTypes );
offsets = linspace( -0.15, 0.15, nExpTypes );

figure
hold on
for expIdx = 1 : length( expList )
    thisExp = expList( expIdx );
    thisExpTab = subTpTab( subTpTab.expID == thisExp, : );

    thisCol = comboLoCol; % default = lo combo
    offset = offsets( 1 );
    
    if thisExpTab.pdDose1( 1 ) == 0.5 & thisExpTab.floorTemp( 1 ) == 31       
            thisCol = comboLoHeatCol;
            offset = offsets( 2 );
    end

    if thisExpTab.pdDose1( 1 ) == 1        
            thisCol = comboHiCol;
            offset = offsets( 3 );
    end

    hAx( expIdx ) = scatterjit( thisExpTab.approxMinCode + offset,...
        thisExpTab.scoreAvg,...
        40, 'filled', 'MarkerFaceColor', thisCol,...
        'MarkerFaceAlpha', 0.7, 'Jit', [ 0.04 0.05 ], 'Axis', 'xy' );

end

% xlim( [ -5 130 ] )
xlim( [ 0.4 4.6 ] )
ylim( [ 0.2 3.8 ] )
% xticks( [ 0 5 30 35 60 120 ] )
xticks( [ 1 : 1 : 4 ] )
xticklabels( [ 5 30 60 120 ] )
yticks( [ 1 : 1 : 4 ] )
xticklabels( [ 5 30 60 120 ] )
xlabel( 'Time after injection (min)' )
ylabel( 'Average tail pinch score' )
legend ( hAx( [ 2 9 1 ] ),... % MAKE THIS BETTER
    { 'Combo 0.5', 'Combo 0.5 + heat support', 'Combo 1' } )
set( hAx, 'FontSize', 12 )





%% Compare IDB and PD scoring.

clear all

IDB = readtable( fullfile( getrootdir, 'Results', 'scores_IDB.xlsx' ) );
PD = readtable( fullfile( 'D:\Dropbox (Personal)\FW_tail_pinch_vids',...
    'scores_PD.xlsx' ) );
scores = table( IDB.tail_pinch_id, PD.score, IDB.score,...
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
if any( abs( difs ) > 0.5 )
    fprintf( [ 'Warning! At least one pinch has an interscorer ',...
        'difference > 0.5.\n' ] )
else
    fprintf( 'Yay! All pinches have an interscorer difference <= 0.5.\n')
end

figure
histogram( difs, [ -1.05 : 0.1 : 1.05 ] )
xticks( [ -1 : 0.5 : 1 ] )
title( 'PD score - IDB score' )

