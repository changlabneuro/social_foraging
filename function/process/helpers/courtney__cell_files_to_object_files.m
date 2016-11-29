function store_objects = courtney__cell_files_to_object_files( files )

assert( isstruct( files ), '<files> must be a struct' );
assert( isfield( files, 'ids'), 'ids are missing' );

all_fields = fieldnames( files );
non_ids = all_fields( ~strcmp( all_fields, 'ids' ) );

store_objects = struct();

for i = 1:numel( non_ids )
    store_objects.( non_ids{i} ) = per_field( files.( non_ids{i} ), files.ids );
end


end

function obj = per_field( one_file, ids )

obj = DataObject();
    
for i = 1:numel( one_file )
    
    obj = obj.append( DataObject( one_file(i), struct( 'sessions', { ids(i) } ) ) );
    
end
    
end