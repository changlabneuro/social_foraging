function obj = courtney__split_percent_per_day( obj, bounds )

msg = 'bounds must be a double with 2 elements, in the range of [0, 1]';

assert( isa( bounds, 'double'), msg );
assert( all( bounds <= 1 & bounds >= 0 ), msg );

indices = obj.getindices( { 'days', 'imageN' } );

obj = obj.addfield( 'percentages' );

store_percentages = [];

for i = 1:numel( indices )
    
    extr = obj( indices{i} );
    
    data = extr.data;
    
    n_trials = size( data, 1 );
    percentages = ( 1:n_trials )';
    
    percentages = percentages / n_trials;
    
    store_percentages = [ store_percentages;percentages ];
    
end

index = store_percentages >= bounds(1) & store_percentages <= bounds(2);

obj = obj( index );
    
% string_percent = cell( numel(percentages), 1 );
% 
% for k = 1:numel( percentages )
%     string_percent{k} = sprintf( '%f', percentages(k) );
% end
% 
% extr( 'percentages' ) = string_percent;
% 
% new_obj = new_obj.append( extr );


end

% binned = cell( 1, ceil( 1/percent ) );
%     
%     while ( current <= 1 )
%         next_max = n_trials * ( current + percent );
%         
%         current_index = percent_index >= current & percent_index <= next_max;
%         
%         binned(stp) = { data(current_index,:) }; stp = stp + 1;
%         
%         current = current + percent;
%     end
%     
%     new_obj = new_obj.append( DataObject( binned, 