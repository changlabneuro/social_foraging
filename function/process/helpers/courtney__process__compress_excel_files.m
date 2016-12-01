function obj = courtney__process__compress_excel_files( obj )

assert( isa( obj, 'DataObjectStruct' ), 'Input must be a DataObjectStruct' );

ignore_fields = { 'images' };

all_fields = obj.objectfields();

for i = 1:numel( ignore_fields )
    all_fields( strcmp( all_fields, ignore_fields{i} ) ) = [];
end

for i = 1:numel( all_fields )
    
    excel_file = obj.( all_fields{i} );
    
    new_excel_file = DataObject();
    
    indices = excel_file.getindices( { 'sessions', 'monkeys' }, 'showProgress' );
    
    for j = 1:numel( indices )
        extr = excel_file( indices{j} );
        extr.data = { extr.data };
        extr = extr(1);
        
        new_excel_file = new_excel_file.append( extr );
    end

    obj = obj.replaceobject( all_fields{i}, new_excel_file );
    
end



end