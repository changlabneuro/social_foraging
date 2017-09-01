function courtney__plot__ak_weights( w, tt, name1, name2, varargin )

params = struct( ...
  'yLim', [], ...
  'SAVE', false, ...
  'savePath', [], ...
  'plotRelative', true ...
);
params = parsestruct( params, varargin );

weights = w.weights;
names = { name1, name2 };
names = cellfun( @(x) strrep(x, '_', ' '), names, 'un', false );

if ( params.plotRelative )
  semilogy( tt, weights.relative, 'r' );
else
  plot( tt, weights.(name1) ); hold on; plot( tt, weights.(name2) );
  legend( names );
  ylim([ -.02, 1.02]);
end
xlim( [min(tt)-1, max(tt)+1] );
ylabel( sprintf('Relative likelihood of %s', names{1}) );
xlabel( 'Travel Time (s)' );

if ( ~isempty(params.yLim) ), ylim( params.yLim ); end;
if ( ~params.SAVE ), return; end;
if ( exist(params.savePath, 'dir') ~= 7 ), mkdir( params.savePath ); end;
assert( ~isempty(params.savePath), 'Specify a save-path as savePath, ''' );
saveas( gcf, fullfile(params.savePath, [name1 '_' name2]), 'epsc' ); close gcf;
% 
% figure;
% plot( tt, aics.discount ); hold on;
% plot( tt, aics.mvt );
% xlim( [min(tt)-1, max(tt)+1] );
% ylim( [min( min([aics.discount(:), aics.mvt(:)]))-10, ...
%   max( max([aics.discount(:), aics.mvt(:)])) + 10] );
% ax = gca;
% set( ax, 'yaxislocation', 'right' );
% legend( {'Discount', 'MVT'} );
% 
% if ( ~isempty(params.yLim) ), ylim( params.yLim ); end;
% if ( ~params.SAVE ), return; end;
% saveas( gcf, fullfile(params.savePath, 'whole_session_aics'), 'epsc' ); close gcf;


end