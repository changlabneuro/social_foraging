function obj = courtney__excel2obj( files )

one_file = getdata( files(1) ); one_file = one_file{1};

fields = fieldnames( one_file ); fields = fields( ~strcmp( fields, 'ids' ) );

store_data = layeredstruct( {fields}, DataObject() );

file_fields = files.fieldnames();

for i = 1:count( files, 1 )
    
    extr = files(i);
    
    data = extr.data{1};
    
    assert( isstruct(data), 'Data was expected to be in a struct' );
    
    ids = data.ids;
    
    for k = 1:numel( fields )
        one_excel_file = data.( fields{k} );
        
        session_ids = cell( 1, numel(one_excel_file) );
        
        for j = 1:numel( ids )
            session_ids{j} = repmat( { ids{j} }, size( one_excel_file{j}, 1), 1 );
        end
        
        one_excel_file = concatenateData( one_excel_file' );
        session_ids = concatenateData( session_ids' );
        
        labels.sessions = session_ids;
        
        new_obj = DataObject( one_excel_file, labels );
        
        new_obj = new_obj.addfield( file_fields );
        
        for j = 1:numel(file_fields)
            new_obj( file_fields{j} ) = extr( file_fields{j} );
        end
        
        store_data.( fields{k} ) = append( store_data.( fields{k} ), new_obj );
    end
end

obj = DataObjectStruct( store_data );

end