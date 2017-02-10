function courtney__plot__ak_weights_over_time( weights, aics, varargin )

params = struct( ...
  'SAVE', false, ...
  'savePath', [] ...
);
params = parsestruct( params, varargin );

tts = aics.travel_time;
legend_tts = strread( num2str(tts), '%s' );

figure;
semilogy( weights.relative' );
legend( legend_tts );
xlim_setter();
xlabel( '% trials per session' );
ylabel( 'Relative performance of MVT model' );

if ( ~params.SAVE ), return; end;
assert( ~isempty(params.savePath), 'Specify a savePath' );
saveas( gcf, fullfile(params.savePath, 'weights'), 'epsc' );
close gcf;

end

function xlim_setter( )

ticks = get( gca, 'xticklabels' );
mins = min( str2double(ticks) );
maxs = max( str2double(ticks) );
for i = 1:numel(ticks)
  nummed = str2double( ticks{i} );
  perc = (nummed - mins) / (maxs - mins);
  ticks{i} = num2str( perc );
end
set( gca, 'xticklabels', ticks );
end