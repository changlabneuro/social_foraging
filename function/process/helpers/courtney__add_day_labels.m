function obj = courtney__add_day_labels( obj )

assert( isa(obj, 'DataObjectStruct' ), 'Input must be a DataObjectStruct' );

obj = obj.foreach( @process_one_object );

end

function obj = process_one_object( obj )

sessions = obj( 'sessions' );
days = cell( size( sessions ) );

for i = 1:numel( sessions )
    days{i} = sessions{i}( ~isstrprop( sessions{i}, 'alpha' ) );
end

obj = obj.addfield( 'days' );
obj( 'days' ) = days;

end