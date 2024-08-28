expID = 14;
metDat = getmetadata( expID );
subj = metDat.subject;
nlynxDir = metDat.nlynxDir;
vidTsFile = metDat.vidFileList{ 5 };
mDatDir = fullfile( getrootdir, 'Data', subj );

ephysLog = fileread( fullfile( mDatDir, nlynxDir, 'CheetahLogFile.txt' ) );
ephysStartTs = regexp( ephysLog,...
    [ '(?<hr>\d{2})\:(?<min>\d{2})\:(?<sec>\d{2}\.\d{3})',...
    '(?: - )\d+(?: - AcquisitionControl::StartRecording)' ],...
    'names' );

vidStartFile = readtable( fullfile( mDatDir, vidTsFile ),...
    'ReadVariableNames', false );
vidStartFile = vidStartFile.Var2{ 1 };
vidStartTs = regexp( vidStartFile,...
    '\D(?<hr>\d{2})\:(?<min>\d{2})\:(?<sec>\d{2}\.\d{4})',...
    'names' );


%% Compare start times.

timescale = { 'hr', 'min', 'sec' };

for i = 1 : 3
    
    ephTs = str2double( ephysStartTs.( timescale{ i } ) );
    vidTs = str2double( vidStartTs.( timescale{ i } ) );
    
    if ephTs ~= vidTs
        disp( vidTs - ephTs )
    end

end




