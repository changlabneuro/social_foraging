function obj = courtney__reformat_excel_travel_times( obj )

assert( isa(obj, 'DataObjectStruct'), 'Input must be a DataObjectStruct' );

images = obj.images;

travel_times = images( 'travelTime' );

for i = 1:numel( travel_times )
    space_index = strfind( travel_times{i}, ' ' );
    
    if ( isempty(space_index) ); continue; end;
    
    travel_times{i} = travel_times{i}( space_index+1:end );
end

images( 'travelTime' ) = travel_times;

obj.objects.images = images;


end