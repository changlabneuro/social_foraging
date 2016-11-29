function [ all_objects, data_fields ] = courtney__fixed_patches_to_obj( patches, session_ids )

assert( iscell(patches), 'Patches must be a cell array of structs' );

fieldmap.labels = struct( ...
    'targetColor', {{{ 2, 'positive' }, { 1, 'negative' }, { 0, 'valence__na' }}}, ...
    'imageFileName', {{ '<copy>' }}, ...
    'trialN', {{ '<copy>' }} ...
);

%     'travelDelayDuration', {{ '<copy>' }} ...

fieldmap.data = { 'patchStartTime', 'imageDisplayedTime', 'decisionTime', ...
    'travelBarSelectedTime', 'travelDelayDuration' };

all_objects = DataObject();

for i = 1:numel( patches )
    
    fieldmap.session = session_ids{i};
    
    all_objects = all_objects.append( per_session( patches{i}, fieldmap ) );
    
end

%   cleanup

all_objects = all_objects.addfield( 'valences' );
all_objects( 'valences' ) = all_objects( 'targetColor' );

data_fields = fieldmap.data;

end

function store_objects = per_session( patch, fieldmap )

label_map = fieldmap.labels;
label_fields = fieldnames( label_map );
data_fields = fieldmap.data;

store_objects = DataObject();

for i = 1:numel( patch )
    
    current = patch(i);
    
    errors = current.decisionTime == 0;
    
    if ( all( errors ) ); continue; end;
    
    current.trialN = ( 1:numel( errors ) )';
    trialN = cell( size( current.trialN ) );
    for k = 1:numel( trialN )    
        trialN{k} = [ 'trial_' num2str( current.trialN(k) ) ];
    end
    
    current.trialN = trialN;
    
    current_labels = layeredstruct( {label_fields}, cell( sum( ~errors ), 1 ) );
    
    for k = 1:numel( label_fields )
        
        actual = current.( label_fields{k} );
        mapping = label_map.( label_fields{k} );
        
        actual = actual( ~errors, : );
        
        if ( isempty( actual ) ); continue; end;
        
        for j = 1:numel( mapping )
            
            current_map = mapping{j};
            
            if ( ~iscell( current_map ) )
                current_labels.( label_fields{k} ) = actual; continue;
            end
            
            switch class( current_map{1} )
                case 'double'
                    current_labels.( label_fields{k} )( actual == current_map{1} ) = current_map(2);
                case 'cell'
                    current_labels.( label_fields{k} )( strcmp(actual, current_map{1}) ) = current_map(2);
            end
        end
        
    end
    
    data = zeros( sum( ~errors ), numel( data_fields ) );
    
    for k = 1:numel( data_fields )        
        actual = current.( data_fields{k} )( ~errors, : );
        
        if ( isempty(actual) ); continue; end;
        
        if ( strcmp( data_fields{k}, 'patchStartTime' ) )
            patch_time = current.( data_fields{k} )(1);
            assert( patch_time ~= 0, 'Patch time was 0' );
            actual = repmat( patch_time , size( actual ) );
        end
        
        if ( strcmp( data_fields{k}, 'travelDelayDuration' ) )
            actual = actual(:, 1);
        end
        
        data(:, k) = actual;
    end
    
    object = DataObject( data, current_labels );
    object = object.addfield( 'patchN' );
    object( 'patchN' ) = [ 'patch__' num2str(i) ];
    
    object = object.addfield( 'sessions' );
    object( 'sessions' ) = { fieldmap.session };
    
    store_objects = store_objects.append( object );
end

end

function patch = fix_travel_delay_duration( patch )

for i = 1:numel( patch )
    current = patch(i);
    
    travel_select_times = current.travelBarSelectedTime;
    
    travel_delays = current.travelDelayDuration;
    new_travel_delays = zeros( size( travel_select_times ) );
    
    non_errors = travel_select_times ~= 0;
    
    new_travel_delays( non_errors ) = travel_delays;
    
    current.travelDelayDuration = new_travel_delays;
    
    patch(i) = current;
end


end