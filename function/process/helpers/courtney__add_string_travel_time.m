function obj = courtney__add_string_travel_time( obj, fields )

assert( isstruct(obj), 'Input must be a struct' );
assert( isfield(obj, 'images'), 'Structure must have an images field' );

travel_time_field = 'travelDelayDuration';

column = find( strcmp( fields.data, travel_time_field ) );

assert( ~isempty(column), sprintf( 'Could not find desired column %s', travel_time_field ) );

images = obj.images;

travel_times = images.data( :, column );

string_travel_times = cell( size( travel_times ) );

for i = 1:numel( string_travel_times )
    string_travel_times{i} = num2str( travel_times(i) );
end

images = images.addfield( 'travelTimes' );
images( 'travelTimes' ) = string_travel_times;

obj.images = images;

end