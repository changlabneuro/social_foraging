function courtney__plot__ak_weights_over_time_rev( weights, tts, ids, varargin )

params = struct( ...
  'SAVE', false, ...
  'savePath', [], ...
  'yLim', [] ...
);
params = parsestruct( params, varargin );

legend_tts = arrayfun( @num2str, tts, 'un', false );
label_ids = cellfun( @(x) strrep(x, '_', ' '), ids, 'un', false );

figure;
semilogy( weights' );
legend( legend_tts );
xlim_setter();
xlabel( '% trials per session' );
ylabel( sprintf('Relative performance of %s model over %s model' ...
  , label_ids{1}, label_ids{2}) );
if ( ~isempty(params.yLim) )
  ylim( params.yLim );
end

if ( ~params.SAVE ), return; end;
full_save_path = fullfile( params.savePath, 'weights' );
if ( exist(params.savePath, 'dir') ~= 7 ); mkdir(params.savePath); end;
assert( ~isempty(params.savePath), 'Specify a savePath' );
filename = sprintf( '%s_%s_weights', ids{1}, ids{2} );
saveas( gcf, fullfile(params.savePath, filename), 'epsc' );
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