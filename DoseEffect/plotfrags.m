%% plot fragments
% ccc
clear all
clc
frags = finddeltafrags( "dex", "delta", "total" );

% Process frags per dose
figure
for i = 1 : length( frags )
    rats{ :, i } = frags( i ).lowDur ./ frags( i ).highDur;
    doses( i ) = frags( i ).dose;
    % plot( doses( i ), rats{ :, i }, '.b',...
    %     "MarkerSize", 20 )%,...
    %     % "MarkerAlpha", 0.6 )
        scatter( doses( i ), rats{ :, i }, 50, 'filled', 'MarkerFaceColor', [ 27,158,119 ] / 255, ...
        "MarkerFaceAlpha", 0.6 )
    hold on

end
box off
xlim( [ -10 160 ] )
ylim( [ -1 10 ] )
hAx = gca;
set( hAx, "XTick", doses )
xlabel( sprintf( "Dex dose (%cg/kg)", 956 ) )
ylabel( "Ratio (\delta_L/\delta_H )" )


% 
% figure
% scatter( doses, rats )



%% plot fragments option B
ccc
frags = finddeltafrags( "dex", "delta", "total" );

% Process frags per dose
figure
hold on
tmpDoses = [ 0 1 2 3 4 5 ];
offset = 0;
loCol = [ 217,95,2 ] / 255;
hiCol = [ 27,158,119 ] / 255;
for i = 1 : length( frags )
    
    realDoses( i ) = frags( i ).dose;
    % doses( i ) = tmpDoses( i );
doses( i ) = frags( i ).dose;
    % scatter( doses( i ) - offset, frags( i ).lowDur / 60,...
    %     'filled', 'MarkerFaceColor', loCol )
    scatter( doses( i ) + offset, frags( i ).highDur / 60,...
        50, 'filled', 'MarkerFaceColor', hiCol, 'MarkerFaceAlpha', 0.6 );
    % bar( doses( i ) - offset, mean( frags( i ).lowDur / 60 ),...
    %     2 * offset, 'FaceColor', loCol, 'FaceAlpha', 0.5, 'EdgeColor', loCol )
    % bar( doses( i ) + offset, mean( frags( i ).highDur / 60 ),...
    %     2 * offset, 'FaceColor', hiCol, 'FaceAlpha', 0.5, 'EdgeColor', hiCol )

end
box off
% xlim( [ -0.9 5.9 ] )
xlim( [ -10 160 ] )
ylim( [ 0 60 ] )
hAx = gca;
set( hAx, "XTick", doses )
set( hAx, "XTickLabels", realDoses )
xlabel( sprintf( "Dex dose (%cg/kg)", 956 ) )
ylabel( "Time spent in \delta_H (min)" )


% 
% figure
% scatter( doses, rats )
