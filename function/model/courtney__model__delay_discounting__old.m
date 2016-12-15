function courtney__model__delay_discounting( fix_psth, varargin )

assert( isa(fix_psth, 'DataObject'), ...
    'Dont'' input the full processed DataObjectStruct -- just the fix_psth object' );

params = struct( ...
    'k', 100, ...
    'sigma', 1e7 ...
);

params = parsestruct( params, varargin );

fix_psth = fix_psth.remove( {'endbatch', 'image_state_maxed_out', 'travelbarselected'} );

indices = fix_psth.getindices( { 'travelTime' } );

for i = 1:numel( indices )
    
    one_tt = fix_psth( indices{i} );
    
    traveltime = str2double( one_tt.uniques( 'travelTime' ) );
    
    binned = courtney__analysis__fix_psth( struct( 'fix_psth', one_tt ) );
    
    params.travelTime = traveltime;
    
    outs = model__per_travel_time( binned.binned, params );
    
    if ( i == 1 ); figure; end;
    
    plot( outs.ll ); hold on;
    
end

legend( fix_psth.uniques( 'travelTime' ) );


end

function outs = model__per_travel_time( psth, params )

traveltime = params.travelTime;
k = params.k;
sigma = params.sigma;

values.leave = zeros( 1, numel( psth ) );
values.stay = zeros( 1, numel( psth ) );

ll = zeros( 1, numel( psth ) );

for i = 1:numel( psth )
    leave = sum( psth ) / ( 1 + k*traveltime );
    stay = sum( psth(i:end) );
    
    values.leave(i) = leave;
    values.stay(i) = stay;
    
    exp_component = exp( (leave - stay) / sigma );
    
    ll(i) = exp_component / ( 1 + exp_component );
end


outs.ll = ll;
outs.values = values;


end