%% plot fragments
ccc
frags = finddeltafrags( "dex", "delta", "total" );

% Process frags per dose
figure
for i = 1 : length( frags )
    rats{ :, i } = frags( i ).lowDur ./ frags( i ).highDur;
    doses( i ) = frags( i ).dose;
    plot( doses( i ), rats{ :, i }, '.b',...
        "MarkerSize", 20,...
        "MarkerAlpha", 0.6 )
    hold on

end
box off
xlim( [ -10 160 ] )
ylim( [ -1 10 ] )
hAx = gca;
set( hAx, "XTick", doses )
xlabel( fprintf( "Dex dose (%cg/kg)", 965 ) )
ylabel( "Ratio (\delta_L\\\delta_H )" )


% 
% figure
% scatter( doses, rats )
