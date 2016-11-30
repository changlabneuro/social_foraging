function combined = courtney__match_objects( excel, patch )

assert( all( [isa(excel, 'DataObjectStruct'), isa(patch, 'DataObjectStruct')] ), ...
    'All inputs must be of type DataObjectStruct' );

objects = objectfields( excel );

assert_fields_exist( patch, objects );

one_object_field = objects{1};

excel_fields = fieldnames( excel.( one_object_field ) );
patch_fields = fieldnames( patch.( one_object_field ) );

uniques = get_uniques( excel_fields, patch_fields );

if ( ~isempty(uniques) )
    patch = patch.addfield( uniques );
end

uniques = get_uniques( patch_fields, excel_fields );

if ( ~isempty(uniques) )
    excel = excel.addfield( uniques );
end

combined = patch.perfield( excel, @append );



end

function uniques = get_uniques( first_fields, second_fields )

uniques = {};
for i = 1:numel( first_fields )
    if ( ~any( strcmp( second_fields, first_fields{i} ) ) )
        uniques = [ uniques; first_fields{i} ];
    end
end
    
end