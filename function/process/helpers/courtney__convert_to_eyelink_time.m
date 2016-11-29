function fixed = courtney__convert_to_eyelink_time(patches, files, fields)

if ( ~isa( files, 'DataObjectStruct' ) )
    files = DataObjectStruct( files );
end

ignore_column_names = { 'travelDelayDuration' };

ignore_columns = [];

for i = 1:numel( ignore_column_names )
    ignore_column = find( strcmp( fields.data, ignore_column_names ) );
    if ( ~isempty( ignore_column ) )
        ignore_columns = [ ignore_columns; ignore_column ];
    end
end

PATCH_START_LABEL = 'patchStartTime';
START_TIME_LABEL = 'RECCFG';

patch_start_column = find( strcmp( fields.data, PATCH_START_LABEL ) );

assert( ~isempty( patch_start_column ), 'Could not locate the desired patch_start_label' );

within = { 'sessions' };

[ indices, combs ] = getindices( patches, within );

fixed = DataObject();

for i = 1:numel( indices )

    extr_patches = patches( indices{i} );

    extr = files.only( combs(i,:) );

    labels = extr.labels.data;
    times = extr.times.data;

    assert( numel(labels) == 1, 'More than one matching session' );

    labels = labels{1};
    times = times{1};
    
    matches = min( find( ...
        cellfun( @(x) ~isempty( strfind( x, START_TIME_LABEL ) ), labels ) ) );

    eyelink_start = times( matches, 2 );
    
    patch_start = min( extr_patches.data( :, patch_start_column ) );
    deltas = extr_patches.data - patch_start; 
    
    deltas = deltas * 1000; %   convert to ms

    eyelink_time = deltas + eyelink_start;

    %   put back the untouched travel delay duration, etc.

    if ( ~isempty( ignore_columns ) )
        for k = 1:numel( ignore_columns )
            eyelink_time( :, ignore_columns(k) ) = extr_patches.data( :, ignore_columns(k) );
        end
    end

    fixed = fixed.append( DataObject( eyelink_time, extr_patches.labels ) );
end


end