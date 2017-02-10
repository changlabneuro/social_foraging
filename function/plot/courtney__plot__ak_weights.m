function courtney__plot__ak_weights( w, aics, varargin )

params = struct( ...
  'yLim', [], ...
  'SAVE', false, ...
  'savePath', [], ...
  'plotRelative', true ...
);
params = parsestruct( params, varargin );

weights = w.weights;
tt = aics.travel_time;

if ( params.plotRelative )
  semilogy( tt, weights.relative, 'r' );
else
  plot( tt, weights.discount ); hold on; plot( tt, weights.mvt );
  legend( {'Discount', 'MVT'} );
  ylim([ -.02, 1.02]);
end
xlim( [min(tt)-1, max(tt)+1] );
ylabel( 'Relative likelihood of MVT' );
xlabel( 'Travel Time (s)' );

if ( ~isempty(params.yLim) ), ylim( params.yLim ); end;
if ( ~params.SAVE ), return; end;
assert( ~isempty(params.savePath), 'Specify a save-path as savePath, ''' );
saveas( gcf, fullfile(params.savePath, 'whole_session_weights'), 'epsc' ); close gcf;
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