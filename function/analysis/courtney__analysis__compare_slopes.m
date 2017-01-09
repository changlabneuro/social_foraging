%{
    courtney__analysis__compare_slopes.m -- resample patch-res
    distributions to determine whether travel-time vs. patch-res time
    correlations differ significantly between conditions. 

    `processed`   (DataObjectStruct) -- all processed data
    `selector1`   (cell array of strings) -- elements specifying the first
        subset of data for which a slope is to be calculated, and the
        TARGET slope value (i.e., p TARGET > COMPARITOR )
    `selector2`   (cell array of strings) -- elements specyfing the second
        subsetof data for which a slope is to be calculated, and the
        COMPARISON slope value

    OPTS ( ... 'name', value)
      `ITERATIONS` -- N resampling epochs
%}

function p = courtney__analysis__compare_slopes(processed, selector1, selector2, varargin)

OPTS = struct( ...
  'ITERATIONS', 100 ...
);

OPTS = parsestruct( OPTS, varargin );

separated.first = processed.only( selector1 );
separated.second = processed.only( selector2 );

assert( all( structfun(@(x) ~isempty(x), separated) ), ... 
  'No data associated with at least one of the desired selectors' );

%   `structfun_nuo` is an alias for calling `structfun` with
%   ( ... 'UniformOutput', false ). Makes things a bit less verbose

psth = structfun_nuo( @(x) courtney__analysis__fix_psth(x, 100), separated );

fields = fieldnames( psth );

%   calculate looking time PSTH for `selector1` and `selector2`

for i = 1:numel( fields )
  pst.(fields{i}) = courtney__analysis__fix_psth( separated.(fields{i}), 100 );
  fits.(fields{i}) = courtney__model__mvt( psth.(fields{i}).summed, ...
    'binnedMeasure', psth.(fields{i}).binned, ...
    'showPlots', false ...
);
end

was_greater = zeros( 1, OPTS.ITERATIONS );

%   get the image object from each DataObjectStruct; then remove nan
%   values, and calculate patch residence

original = structfun_nuo( @(x) x.images, separated );
original = structfun_nuo( @(x) remove_nans(x), original );
original = structfun_nuo( @(x) get_patch_res(x), original );

for i = 1:OPTS.ITERATIONS
  
  resampled = original;
  resampled = structfun_nuo( @(x) resample_per_tt(x), resampled );
  
  for k = 1:numel(fields)
    tt_observed.(fields{k}) = courtney__analysis__tt_v_patchres( ...
        resampled.(fields{k}), fits.(fields{k}).travelTime_vs_patchResidence, ...
        'maxPatchTime', 15e3 );
    rs.(fields{k}) = tt_observed.(fields{k}).correlations.observed(1);
  end
  
  was_greater(i) = rs.first > rs.second;
    
end

p = 1 - ( sum(was_greater) / OPTS.ITERATIONS );

end

function obj = remove_nans( obj )
  nans = isnan( obj.data(:,3) );
  obj = obj( ~nans );
end

function obj = get_patch_res( obj )
  new_data = [obj.data(:,2) - obj.data(:,1), obj.data(:,3)];
  obj.data = new_data;
end

function obj = resample_per_tt( obj )

  data = obj.data;

  tts = unique( data(:,2) );
  
  new_data = zeros( size(data) );
  stp = 0;
  
  for i = 1:numel(tts)    
    extr = data( data(:,2) == tts(i), : );
    current_size = size( extr, 1 );
    extr(:, 1) = datasample( extr(:,1), current_size );       
    new_data(stp+1:stp+current_size, :) = extr;
    stp = stp + current_size;
  end
  
  obj.data = new_data;
  
end

function S = structfun_nuo( func, S )

S = structfun( func, S, 'UniformOutput', false );

end
