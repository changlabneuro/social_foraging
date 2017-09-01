function [aics, weights] = courtney__model__aic_difference_over_time( processed, varargin )

params = struct( ...
  'resolution', .2 ...
);

params = parsestruct( params, varargin );
resolution = params.resolution;
N = floor( 1 / resolution );
stp = 0;

for i = 1:N
  start = stp; 
  stop = start + resolution;
  stp = stop;
  
  separated = processed.foreach( ...
    @courtney__split_percent_per_day, [start stop], {'days'} );
  
  [mvts, discount, only_r_term, only_t_terms] = ...
    courtney__model__sci_rev( separated, separated.images, ...
    'showPlots', false );
  
  aics = courtney__model__get_aic( discount, mvts );
  weights = courtney__model__get_ak_weights( aics );
  difference = aics.discount - aics.mvt;
  
  if ( i == 1 )
    discount_aics = zeros( numel(difference), N ); 
    mvt_aics = zeros( numel(difference), N );
    difference_aics = zeros( numel(difference), N );
    relative_weights = zeros( size(difference_aics) );
  end
  
  discount_aics(:,i) = aics.discount(:);
  mvt_aics(:,i) = aics.mvt(:);
  difference_aics(:,i) = difference(:);
  relative_weights(:,i) = weights.weights.relative(:);
  
end

aics.discount = discount_aics;
aics.mvt = mvt_aics;
aics.difference = difference_aics;
weights.relative = relative_weights;
% tts = repmat( aics.travel_time(:), [1, size(mvt_aics,2)] );

end