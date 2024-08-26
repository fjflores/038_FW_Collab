%% Adjust flir video quality
ccc
root = getrootdir();
dataDir = fullfile( getrootdir(), 'Data', 'M101' );
vidName = 'flir_vid_2024-08-07T15_50_36.avi';
videoFile = fullfile( dataDir, vidName );

videoObj = VideoReader( videoFile );

% Create a VideoWriter object to write the modified frames to a new video file
outputFile = 'path/to/output/file.mp4';
outputObj = VideoWriter(outputFile, 'MPEG-4');

%% Create figure for plotting
frame = zeros( videoObj.Height, videoObj.Width, 3, 'uint8' );

figure
subplot( 1, 2, 1 );
h1 = imagesc( frame );
axis equal
colormap( gray )

subplot( 1, 2, 2 );
h2 = imagesc( frame );
axis equal
colormap( gray )

%%
for i = 1 : 300
    rawFrame = readFrame( videoObj );

    % Improve the brightness of the frame
    adjustedFrame = imadjust( rawFrame, [ 0 0 0; 0.15 0.15 0.15 ], [ ] );
    
    set( h1, 'CData', rawFrame );
    set( h2, 'CData', adjustedFrame );

    pause( 1 /30 )

end

