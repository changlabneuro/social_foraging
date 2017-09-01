function [store, C, tt] = courtney__model__aic_difference_over_time_rev( processed, varargin )

params.resolution = .2;
params.combinations = [];
% params.combinations = {'only_r_term', 'discount'; 'only_t_terms', 'discount' };

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
  
  fits = struct();
  
  [fits.mvt, fits.discount, fits.only_r_term, fits.only_t_terms] = ...
    courtney__model__sci_rev( separated, separated.images, ...
    'showPlots', false );
  
  if ( isempty(params.combinations) )
    fnames = fieldnames(fits);
    C = combnk( fnames, 2 );
  else
    C = params.combinations;
  end
  
  for k = 1:size(C, 1)
    name1 = C{k, 1};
    name2 = C{k, 2};
    
    aic1 = courtney__model__get_aic2( fits.(name1) );
    aic2 = courtney__model__get_aic2( fits.(name2) );
  
    weights = ...
      courtney__model__get_ak_weights2( aic1.(name1), aic2.(name2), name1, name2 );
    
    relative = weights.weights.relative;
    
    if ( i == 1 && k == 1 )
      store = cell( 1, size(k, 1) );
      tt = aic1.travel_time;
    end
    
    store{k}(:, i) = relative;
  end  
end

end