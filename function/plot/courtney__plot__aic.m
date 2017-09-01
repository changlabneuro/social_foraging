function courtney__plot__aic( aic1, aic2, varargin )

params = struct( ...
  'yLim', [], ...
  'SAVE', false, ...
  'savePath', [], ...
  'yAxisLocation', 'left' ...
);
params = parsestruct( params, varargin );

tt = aic1.travel_time;
name1 = char( setdiff(fieldnames(aic1), 'travel_time') );
name2 = char( setdiff(fieldnames(aic2), 'travel_time') );

figure; hold on;
plot( tt, aic1.(name1), 'r' );
plot( tt, aic2.(name2), 'b' );

names = { name1, name2 };
names = cellfun( @(x) strrep(x, '_', ' '), names, 'un', false );

legend( names );
xlim( [min(tt)-1, max(tt)+1] );
ylabel( 'AIC' );
xlabel( 'Travel Time (s)' );

if ( strcmp(params.yAxisLocation, 'right') )
  ax = gca;
  set( ax, 'yaxislocation', 'right' );
end

if ( ~isempty(params.yLim) ), ylim( params.yLim ); end;
if ( ~params.SAVE ), return; end;
if ( exist(params.savePath, 'dir') ~= 7 ), mkdir(params.savePath); end;
assert( ~isempty(params.savePath), 'Specify a save-path as savePath, ''' );
filename = fullfile( params.savePath, [name1, '_' name2] );
saveas( gcf, filename, 'epsc' ); close gcf;

end