function binned = courtney__analysis__binned_fix_dur( fixs, binsize, varargin )

params = struct( ...
  'imageLength', 15e3, ...
  'minLength', 1e2 ...
  );

params = parsestruct( params, varargin );

image_length = params.imageLength;
min_length = params.minLength;

bins = ceil( image_length / binsize );

thresh = fixs.data(:, 2) > min_length;
fixs = fixs( thresh );

data = fixs.data;
starts = data(:, 1);
lengths = data(:, 2);

stp = 0;

binned = zeros( 1, bins );

for i = 1:bins
  ind = starts >= stp & starts < stp+binsize;
  if ( ~any(ind) ), binned(i) = 0; continue; end;
  extr = lengths( ind );
  binned(i) = mean( extr );
  stp = stp + binsize;
end

end