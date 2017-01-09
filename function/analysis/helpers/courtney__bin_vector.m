function binned = courtney__bin_vector( arr, binsize, method )

nbins = ceil( numel(arr) / binsize );
i = 1; terminus = binsize; start = 1;
binned = zeros( 1, nbins );

while ( terminus <= numel(arr) )  
  bin = get_bin( arr, start, terminus, method );
  binned(i) = bin;
  i = i + 1;
  start = start + binsize;
  terminus = terminus + binsize;
end

%   if there are leftovers, have the last bin contain the leftovers

if ( numel(arr) - start - 1 > 0 )
  binned(end) = get_bin( arr, start, numel(arr), method );
end


end

function bin = get_bin( arr, start, terminus, method )

switch ( method )
  case 'mean'
    bin = mean( arr(start:terminus) );
  case 'sum'
    bin = sum( arr(start:terminus) );
  otherwise
    error( ...
      'Possible methods are ''mean'' and ''sum''; input was ''%s''', method );
end



end