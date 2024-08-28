function DLCcm = pix2cm( DLCpix )
% PIX2CM converts DLC coordinates (or speeds) in pixels into centimeters.
% 
% Usage: 
% DLCcm = pix2cm( DLCpix )
% 
% Input: 
% DLCpix: table or array containing DLC coordinates, deltas, and/or speeds 
% in pixels. Note: cannot handle raw DLC data straight from DLC csv.
% 
% Output: 
% DLCcm: same format as DLCpix input, now converted into cm.
% 
% Note: The conversion from pixels to cm for camera position used for 
% ephys cohorts 1 and 2 is 15.07 pixels/1 cm, as determined by photoshop
% analysis of picture of ruler in round cage.

pixPerCm = 15.07;
pixCheckMsg = [ 'Aborting pix to cm conversion. Looks like the input ',...
                'DLC data was already converted to cm.' ];
            
switch class( DLCpix )
    case { 'table' }
        if strcmpi( table2array( DLCpix( 1, 1 ) ), 'scorer' )
            error( [ 'Aborting pix to cm conversion. Please use ',...
                'loaddlccsv.m to load raw DLC csv ',...
                'before using pix2cm.m.' ] )
        else
            DLCcm = DLCpix;
            % ignore columns that are 'frameNum' or '*_likelihood'
            varNams = DLCcm.Properties.VariableNames;
            cols2convert = ~contains( varNams, { 'frame', 'likelihood' } );
            tmpPix = table2array( DLCcm( :, cols2convert ) );
            assert( checkpixunits( tmpPix ), pixCheckMsg );
            tmpMm = tmpPix ./ pixPerCm;
            DLCcm( :, cols2convert ) = array2table( tmpMm );
            
        end
        
    case { 'double' }
        assert( checkpixunits( DLCPix ), pixCheckMsg );
        DLCcm = DLCpix ./ pixPerCm;
                
end
    
  
end

function pixFlag = checkpixunits( DLCpix )
% Mini helper function to check if input data is likely in pixels or has
% likely already been converted to cm. 

% All cohort 1's max x, y, and speed are well over 100, so using that as a
% cutoff for likely pixel units.

pixTest = max( DLCpix );
if mean( pixTest ) < 100 
    pixFlag = false;
else
    pixFlag = true;
end


end

