function [store_targ_order, bad_sessions] = courtney__analysis__excel_target_order( labels )

assert( isa(labels, 'DataObject'), 'Input <labels> must be a DataObject' );

within = { 'monkeys', 'sessions' };

indices = labels.getindices( within );

store_targ_order = DataObject();

bad_sessions = {};

for i = 1:numel( indices )
    
    one_session = labels( indices{i} );
    assert( numel( one_session.data ) == 1, 'More than one element present' );
    one_session_data = one_session.data;
    
    try
        orders = targOrder( one_session_data );
    catch
        session = one_session.uniques( 'sessions' ); bad_sessions = [ bad_sessions; session ];
        continue;
    end
    
    one_session_labels = one_session.replabels( size(orders,1) );
    
    store_targ_order = store_targ_order.append( DataObject( orders, one_session_labels ) );
end



end