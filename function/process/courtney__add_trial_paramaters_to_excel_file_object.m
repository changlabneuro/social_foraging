function store_images = courtney__add_trial_paramaters_to_excel_file_object( obj )

assert( isa( obj, 'DataObjectStruct' ), 'Input must a DataObjectStruct' );
assert_fields_exist( obj, {'labels','times','events'} );

within = { 'sessions' };

indices = obj.foreach( @getindices, within );

for i = 1:numel( indices.labels )
    
    fprintf( '\nProcessing %d of %d', i, numel( indices.labels ) );
    
    s.type = '{}'; s.subs = { i };
    
    %   for each 'fieldname' in <indices>,
    %   return indices.( 'fieldname' ){ i };
    
    extr_index = indices.foreach( @subsref, s );
    
    %   for each DataObject in <obj>, extract the data associated with its
    %   corresponding index in <extr_index>
    
    extr_obj = obj.perfield( extr_index, @index );
    
    %   get the eye-link flags (labels) separately
    
    extr_labels = getdata( extr_obj.labels );
    
    %   for each session (or whatever is defined in <within> above), return
    %   the original <extr> struct (with all of the excel file info) but
    %   with an additional field <images> -- <images> is a DataObject where
    %   each row in <images.data> corresponds to a start and end time for
    %   an image presentation. Various other identifiers are associated
    %   with each start and end time in order to make separating images
    %   easier
    
    images = add_trial_paramaters( extr_obj, extr_labels );
    
    if ( i == 1 ); store_images = images; continue; end;
    
    store_images = store_images.perfield( images, @append );
end

end

function extr = add_trial_paramaters( extr, labels )

data_fields = { 'startTime', 'endTime' };
label_fields = { 'valence', 'social', 'expressionCode', 'travelTime' };

times = extr.times.data( :, 2 );

in_markers.trialStart = { 'ImageDisplayed' };
in_markers.trialEnd = { 'TravelBarSelected', 'Image_State_Maxed_Out' };
in_markers.isValence = { 'pos', 'neg' };
in_markers.isSocial = { 'soc', 'non' };
in_markers.travelTime = { 'TT_use: ' };
in_markers.nextPatch = { '' };

check_validity.validImageType = false;
check_validity.validStartAndEndTime = false;
check_validity.validTravelTime = false;

%   preallocate analyzed markers

images = cell( size(labels, 1) - 3, 1 );

for i = 1:length( labels ) - 3
    
    %   set all fields -> false
    
    check_validity = structfun( @(x) false, check_validity, 'UniformOutput', false );
    
    images{ i } = struct();
    images{ i }.validity = check_validity;
    
    %   first let's locate the image start and end time
    
    current_label = char( labels{ i } );
    next_label = char( labels{ i+3 } );
    
    found_start = any( strcmp( in_markers.trialStart, current_label ) );
    found_end = any( strcmp( in_markers.trialEnd, next_label ) );
    
    %   if the current label pair doesn't define an image presentation,
    %   move on
    
    if ~( found_start && found_end ); continue; end;
    
    images{ i }.validity.validStartAndEndTime = true;
    
    %   mark the start and end times, since we found them
    
    images{ i }.startTime = times( i );
    images{ i }.endTime = times( i + 3 );
    
    image_type = char( labels{ i-1 } );
    
    %   only proceed if the image type is valid
    
    if ( length( image_type ) < 3 ); continue; end;
    
    %   check the first three characters of image_type against the mappings
    %   defined in <markers> to determine the image_type, and store in
    %   <out_markers>
    
    full_image_type = image_type;
    image_type = image_type( 1:3 );
    
    %   valence
    
    if ( any( strcmp( in_markers.isValence, image_type ) ) )
        images{ i }.valence = { image_type };
        images{ i }.social = { 'social__na' };
        images{ i }.validity.validImageType = true;
    end
    
    %   social
    
    if ( any( strcmp( in_markers.isSocial, image_type ) ) )
        images{ i }.valence = { 'valence__na' };
        images{ i }.social = { image_type };
        images{ i }.validity.validImageType = true;
    end
    
    %   if we couldn't find an image type, continue
    
    if ( ~images{ i }.validity.validImageType ); continue; end;
    
    %   otherwise, get the expression of the image
    
    expression_code = courtney__find_exp_code( full_image_type );
    
    if ( isempty( expression_code ) ); expression_code = 'expression__na'; end;
    
    images{ i }.expressionCode = { expression_code };
    
    %   get the travel time associated with the image
    
    %   there are two possible ways travel time is coded. This is the more
    %   straightforward way things are coded -- travel time preceeds the
    %   image presentation marker by 2
    
    first_possible_travel_time = labels{ i - 2 };
    
    found_travel_time = ~isempty( strfind( first_possible_travel_time, 'TT_use: ' ) );
    
    if ( found_travel_time );
        images{ i }.travelTime = { first_possible_travel_time }; 
        images{ i }.validity.validTravelTime = true;
        continue;
    end;
    
    %   otherwise, travel time is marked after the final TravelBarSelected
    %   flag in sequence
      
    step = 0; max_search = length( labels ) - 3;
    while ( strcmp( labels{ i + 3 + step }, 'TravelBarSelected' ) ...
            && ( i + 3 + step ) < max_search );
        step = step + 1;
    end
    
    images{ i }.travelTime = labels( i + 3 + step );
    images{ i }.validity.validTravelTime = true;
end

all_errors = false( size( images ) );

for i = 1:numel( images )
    current_validity = images{ i }.validity;
    all_errors( i ) = any( structfun( @(x) ~x, current_validity ) );
end

images( all_errors ) = [];

%   now put the image times in DataObject form

data = zeros( numel( images ), numel( data_fields ) );
data_labels = layeredstruct( { label_fields }, cell( size( images ) ) );

for i = 1:numel( images )
    for k = 1:numel( data_fields )
        data( i, k ) = images{ i }.( data_fields{ k } );
    end
end

for i = 1:numel( images )
    for k = 1:numel( label_fields )
        data_labels.( label_fields{k} )( i ) = images{ i }.( label_fields{ k } );
    end
end

%   convert to object

image_object = DataObject( data, data_labels );

%   add data_labels from <extr> to <image_object>

object_fields = extr.labels.fieldnames();

for i = 1:numel( object_fields )
    additional_labels = extr.labels.uniques( object_fields{ i } );
    
    assert( numel(additional_labels) == 1, ...
        'More than one label identifies this datapoint' );
    
    additional_labels = repmat( additional_labels, size( images ) );
    
    image_object = image_object.addfield( object_fields{ i } );
    
    image_object( object_fields{ i } ) = additional_labels;
end

%   some cleanup

replacements = { ...
    { 'social', 'block__social' }, { 'non', 'nonsocial' }, ...
    { 'soc', 'social' }, { 'valence', 'block__valence' }, ...
    { 'color_control', 'block__color_control' } ...
};

for i = 1:numel( replacements )
    image_object = image_object.replace( replacements{i}{:} );
end

image_object = image_object.lower();    %   make labels lower-case

extr = extr.addobject( image_object, 'images' );

end

function code = courtney__find_exp_code( str )

backslash = strfind( str, '\' );

if ( isempty( backslash ) ); 
    code = []; return;
end;

code = str( backslash + 1:backslash + 2 );

code = code( isstrprop( code, 'alpha' ) );

end