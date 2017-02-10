function psth = courtney__analysis__look_proportion( proportion, bin_size, method )

if ( nargin < 3 ), method = 'mean'; end;

prop = courtney__bin_vector( mean(proportion.data), bin_size, method );
psth.binned = prop;
psth.summed = cumsum( prop );

end