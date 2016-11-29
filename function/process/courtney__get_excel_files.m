function store_files = courtney__get_excel_files( outerfolder )

if ( nargin == 0 )
    outerfolder = '/Volumes/My Passport/NICK/Chang Lab 2016/courtney/behavioral/data/112216';
end

folders = remDir( dirstruct( outerfolder, 'folders' ) );

store_files = DataObject();

for i = 1:numel(folders)    
    monkey_path = fullfile( outerfolder, folders(i).name );
    
    subfolders = dirstruct( monkey_path, 'folders' );
    
    labels.monkey = { folders(i).name };
    
    for k = 1:numel(subfolders)
        
        subfolder_path = fullfile( monkey_path, subfolders(k).name );
        
        excel_files_are_missing = isempty( dirstruct( subfolder_path, '.xls' ) );
        
        if ( excel_files_are_missing ); continue; end;
        
        files = getFiles( subfolder_path );
        
        labels.blocktype = { subfolders(k).name };
        
        store_files = store_files.append( DataObject( { files }, labels ) );
    end   
end

end