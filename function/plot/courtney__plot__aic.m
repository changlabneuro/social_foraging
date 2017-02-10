function courtney__plot__aic( aics, varargin )

params = struct( ...
  'yLim', [], ...
  'SAVE', false, ...
  'savePath', [], ...
  'yAxisLocation', 'left' ...
);
params = parsestruct( params, varargin );

tt = aics.travel_time;

figure; hold on;
plot( tt, aics.discount, 'r' );
plot( tt, aics.mvt, 'b' );

legend( {'Discount', 'MVT'} );
xlim( [min(tt)-1, max(tt)+1] );
ylabel( 'AIC' );
xlabel( 'Travel Time (s)' );

if ( strcmp(params.yAxisLocation, 'right') )
  ax = gca;
  set( ax, 'yaxislocation', 'right' );
end

if ( ~isempty(params.yLim) ), ylim( params.yLim ); end;
if ( ~params.SAVE ), return; end;
assert( ~isempty(params.savePath), 'Specify a save-path as savePath, ''' );
saveas( gcf, fullfile(params.savePath, 'whole_session'), 'epsc' ); close gcf;

end