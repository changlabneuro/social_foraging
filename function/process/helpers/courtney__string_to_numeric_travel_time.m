function obj = courtney__string_to_numeric_travel_time( obj )

assert( isa(obj, 'DataObjectStruct'), '<obj> must be a DataObjectStruct' );

images = obj.images;

traveltimes = images( 'travelTime' );

numeric = nan( size( traveltimes ) );

for i = 1:size( numeric, 1 )

    current_label = traveltimes{ i };

    space_index = strfind( current_label, ' ' );

    if ( isempty( space_index ) ); continue; end;

    time = str2double( current_label( space_index + 1:end ) );
    
    numeric( i ) = time;
end

data = images.data;

data(:, end + 1) = numeric;

images.data = data;
obj.objects.images = images;

end