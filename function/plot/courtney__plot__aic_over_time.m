function courtney__plot__aic_over_time( aics, varargin )

params = struct( ...
  'SAVE', false, ...
  'savePath', [] ...
);
params = parsestruct( params, varargin );

tts = aics.travel_time;
legend_tts = strread( num2str(tts), '%s' );

%   figure out ylims

mins = min([aics.mvt(:); aics.discount(:)]);
maxs = max([aics.mvt(:); aics.discount(:)]);

figure;
plot( aics.mvt' );
legend( legend_tts );
ylim( [mins, maxs] );
xlim_setter();
xlabel( '% trials per session' );

if ( params.SAVE )
  assert( ~isempty(params.savePath), 'Specify a savePath' );
  saveas( gcf, fullfile(params.savePath, 'mvt_aics'), 'epsc' );
  close gcf;
end

figure;
plot( aics.discount' );
legend( legend_tts );
ylim( [mins, maxs] );
xlim_setter();
xlabel( '% trials per session' );

if ( params.SAVE )
  assert( ~isempty(params.savePath), 'Specify a savePath' );
  saveas( gcf, fullfile(params.savePath, 'discount_aics'), 'epsc' );
  close gcf;
end

figure;
plot( aics.difference' );
legend( legend_tts );
xlim_setter();
xlabel( '% trials per session' );

if ( params.SAVE )
  assert( ~isempty(params.savePath), 'Specify a savePath' );
  saveas( gcf, fullfile(params.savePath, 'difference_aics'), 'epsc' );
  close gcf;
end


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