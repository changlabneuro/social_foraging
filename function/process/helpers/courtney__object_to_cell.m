function [ cells, sessions ] = courtney__object_to_cell( obj )

sessions = obj.uniques( 'sessions' );

n_sessions = numel( sessions );

indices = obj.getindices( 'sessions' );

cells = cell( 1, n_sessions );

for i = 1:numel( indices )
    one_session = obj( indices{i} );    
    
    cells{i} = one_session.data;
end

end