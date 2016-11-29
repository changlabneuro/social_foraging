function orders = courtney__analysis__target_order( obj )

max_n_trials = 8;

assert( isa(obj, 'DataObject'), 'Input must be a DataObject' );

within = { 'sessions', 'patchN' };

indices = obj.getindices( within );

orders = nan( 1000, max_n_trials );

for i = 1:numel( indices )
    extr = obj( indices{i} );
    
    trials = extr.uniques( 'trialN' );
    
    extr = extr.orderby( trials );
    
    valences = extr.labels.valences;
    
    current_orders = zeros( 1, numel(valences) );
    current_orders( strcmp(valences, 'positive') ) = 1;
    
    orders(i, 1:numel(current_orders) ) = current_orders;
end

keep_index = ~isnan( orders(:,1) );

orders = orders( keep_index, : );

end