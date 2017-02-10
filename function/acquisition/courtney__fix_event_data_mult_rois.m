function store_across_sessions = courtney__fix_event_data_mult_rois( obj, fields, varargin )

start_col = find( strcmp( fields.data, 'imageDisplayedTime' ) );
end_col = find( strcmp( fields.data, 'travelBarSelectedTime' ) );

assert( all( [~isempty(start_col), ~isempty(end_col)] ), ...
    'Could not find start or end col' );

params = struct( ...
    'startTimeColumn', start_col, ...
    'endTimeColumn', end_col, ...
    'fix_psth_preallocation_amount', 15e3, ...
    'roi', struct( 'minX', -10e3, 'maxX', 10e3, 'minY', -10e3, 'maxY', 10e3 ), ...
    'n_divisions', 10 ...
);

% 'roi', struct( 'minX', 600, 'maxX', 1200, 'minY', 150, 'maxY', 750 ), ...

params = parsestruct( params, varargin );

params = create_rois( params );

obj = validate_input( obj );

travel_delay_col = find( strcmp( fields.data, 'travelDelayDuration' ) );
valid_trials = obj.images.data(:, travel_delay_col) ~= 0;
obj.objects.images = obj.images( valid_trials );

within = { 'sessions' };

[ indices, combs ] = getindices( obj.images, within );

for i = 1:numel( indices )
    
    fprintf( '\nProcessing %d of %d', i, numel(indices) );
    
    extr = obj.only( combs( i,: ) );
    
    one_session = per_session( extr, params );
    
    if ( i == 1 ); store_across_sessions = one_session; continue; end;
    
    store_across_sessions = store_across_sessions.perfield( one_session, @append );
end

end


function store_all = per_session( obj, params )

per_image_fields = { 'looking_duration', 'n_fixations', 'fix_psth', 'proportion' };

if ( strcmp( obj.events.dtype, 'cell' ) )
    assert( count( obj.events, 1 ) == 1, 'More than one events file was found for this session' );

    events = obj.events.data{ 1 };
else events = obj.events.data;
end

obj = obj.addfield( 'imageN' );

images = obj.images;

image_number = 1;

image_starts = images.data(:, params.startTimeColumn);
image_ends = images.data(:, params.endTimeColumn);

fix_starts = events(:, 1);
fix_ends = events(:, 2);

roi = params.roi;

store_per_image = layeredstruct( { per_image_fields }, DataObject() );
store_per_fix = DataObject();

debug__log = false( numel( image_starts ), 1 );

valid_images = false( size( debug__log ) );

for i = 1:numel( image_starts )
    
    labels = images( i ); labels = labels.labels;
    
    image_start = image_starts(i, 1);
    image_end = image_ends(i, 1);
        
    if ( image_end > max( fix_ends ) ); % if invalid display time
        continue;
    end
    
    %   start index is the index of the first fixation *endtime* that
    %       occurred after the image was presented. 
    %   end index is the index of the final fixation *starttime* that
    %       occurred before the image ended.
    
%     start_index = find( fix_starts >= image_start, 1, 'first' );
    start_index = find( fix_ends >= image_start, 1, 'first' );
    %   OPTION 1 -- fixations are only considered valid if they end before
    %   the image ends
%     end_index = find( fix_ends <= image_end, 1, 'last' );
    %   OPTION 2 -- fixations *are* considered valid so long as they being
    %   before they the image ends
    end_index = find( fix_starts < image_end, 1, 'last' );

    %   validate

    if ( end_index < start_index )
        debug__log(i) = true; continue;
    end

    if ( isempty(end_index) || isempty(start_index) )
        error('Could not find a start or end index');
    end

    %   if the first fixation started before the image was presented,
    %   the first fixation length is the first fixation end time minus
    %   the image start time

    if ( ( image_start - fix_starts(start_index) ) < 0 )
        events( start_index, 3 ) = fix_ends( start_index ) - image_start;
    end
    
    %   if the last fixation ended after the image ended, the last
    %   fixation duration is the image end time minus the final
    %   fixation start time

    if ( (image_end - fix_ends( end_index )) < 0 && start_index ~= end_index )
        events( end_index, 3 ) = image_end - fix_starts( end_index );        
    end

    within_time_bounds = events( start_index:end_index,: );

    if ( any( within_time_bounds(:,3) < 0 ) )
        error( 'Impossible fixation duration' );
    end

    %   remove out of bounds data

    within_pos_bounds = ...
        within_time_bounds(:,4) >= roi.minX & ...
        within_time_bounds(:,4) <= roi.maxX & ...
        within_time_bounds(:,5) >= roi.minY & ...
        within_time_bounds(:,5) <= roi.maxY;

    within_time_bounds = within_time_bounds( within_pos_bounds, : );
    
    if ( isempty( within_time_bounds ) ); continue; end;
    
    %   mark that this is a valid image
    
    valid_images(i) = true;
    
    %   proportion of image seen over time
    
%     prop = get_proportion_of_image_seen_over_time( within_time_bounds, image_start, params );
    prop = 0;
    
    %   data per image
    
    per_image.looking_duration = sum( within_time_bounds(:, 3) );
    per_image.n_fixations = size( within_time_bounds, 1 );
    per_image.proportion = prop;
    
    %   fix event psth -- still per image
    
    index_vector = ( round( image_start ):round( image_end ));
    vector = zeros( 1, round( image_end ) - round( image_start ));
    
    for k = 1:size( within_time_bounds, 1 )
        current_fix_start = within_time_bounds( k, 1 );
        current_fix_end = within_time_bounds( k, 2);
        
        indices.fix_start = find( index_vector == current_fix_start );
        indices.fix_end = find( index_vector == current_fix_end );
        
        vector( indices.fix_start:indices.fix_end ) = 1;
    end
    
    per_image.fix_psth = zeros( 1, params.fix_psth_preallocation_amount );
    per_image.fix_psth( 1:numel(vector) ) = vector;
    
    %   data per fix event
    
    per_fixation = { within_time_bounds };
    
    store_per_fix = store_per_fix.append( DataObject( {per_fixation}, labels ) );
    
    for k = 1:numel( per_image_fields )
        store_per_image.( per_image_fields{k} ) = ...
            append( store_per_image.( per_image_fields{k} ), ...
            DataObject( per_image.( per_image_fields{k} ), labels ) );
    end
    
    %   store the image number associated with each DataPoint
    
    image_number_string = [ 'image__' num2str( image_number ) ];
    
    store_per_fix( 'imageN', image_number ) = image_number_string;
    store_per_image = structfun( @(x) x.setfield( ...
        'imageN', image_number_string, image_number ), ...
        store_per_image, 'UniformOutput', false );
    
    image_number = image_number + 1;
end

processed_images = images( valid_images );
processed_images( 'imageN' ) = store_per_image.( per_image_fields{1} )( 'imageN' );

store_per_image = DataObjectStruct( store_per_image );

store_all = store_per_image;
store_all = store_all.addobject( store_per_fix, 'fix_events' );
store_all = store_all.addobject( processed_images, 'images' );

end

function flattened = flatten( obj )

flattened = DataObject();

for i = 1:count( obj, 1 )
   extr = obj(i);
   data = extr.data{1}{1};
   
   extr_size = size( data, 1 );
   
   input.data = data;
   
   labels = extr.labels;
   fields = extr.fieldnames();
   
   for k = 1:numel( fields )
       labels.( fields{k} ) = repmat( labels.( fields{k} ), extr_size, 1 );
   end
   
   input.labels = labels;
   
   flattened = flattened.append( DataObject( input ) );
   
end

end

function obj = validate_input( obj )
    
    if ( isstruct( obj ) )
        obj = DataObjectStruct( obj );
    end

    assert( isa(obj, 'DataObjectStruct'), ...
        'Input must be a DataObjectStruct or a regular struct' );
    
    assert_fields_exist( obj, { 'labels', 'times', 'events', 'images' } );
end

function params = create_rois( params )

roi = params.roi;
div = params.n_divisions;

x = (roi.maxX - roi.minX) / div;
y = (roi.maxY - roi.minY) / div;

xs = roi.minX:x:roi.maxX;
ys = roi.minY:y:roi.maxY;

rois = cell( div*div, 1 );
stp = 1;
for i = 1:numel(xs) - 1
  for j = 1:numel(ys) - 1
    r = struct();
    r.minX = xs(i);
    r.maxX = xs(i+1);
    r.minY = ys(j);
    r.maxY = ys(j+1);
    rois{stp} = r;
    stp = stp + 1;
  end
end

params.rois = rois;

end

function explored_vector = get_proportion_of_image_seen_over_time( evts, start, params )

%   get the proportion of the image seen

vec_size = params.fix_psth_preallocation_amount;
roi = params.roi;
rois = params.rois;

explored_vector = ones( 1, vec_size );

inds = get_indices_from_evts( evts, rois );

cumulative = 1;

while ( ~isempty(inds) )
  area_prop = get_area_proportion( roi, rois{inds(1)} );
  current = evts(1, :);
  current_indices = current(1:2) - start;
  
  if ( current_indices(1) < 0 ), current_indices(1) = 0; end;
  if ( current_indices(2) > vec_size ), current_indices(2) = vec_size; end;
  
  cumulative = cumulative - area_prop;
  
  explored_vector( current_indices(2):end ) = cumulative;
  
  inds(1) = [];
  evts(1,:) = [];
end

end

function inds = get_indices_from_evts( evts, rois )

inds = zeros( size(evts,1), 1 );

for i = 1:size(evts, 1)
  stp = 1;
  while ( ~is_withinbounds( evts(i,:), rois{stp} ) )
    stp = stp + 1;
  end
  inds(i) = stp;
end

end

function bool = is_withinbounds( evts, roi )

bool = ...
  evts(:,4) >= roi.minX & ...
  evts(:,4) <= roi.maxX & ...
  evts(:,5) >= roi.minY & ...
  evts(:,5) <= roi.maxY;

end

function prop = get_area_proportion( image_roi, sub_roi )

prop = sqrt( get_area(sub_roi) / get_area(image_roi) );

end

function area = get_area( roi )

area = (roi.maxX - roi.minX) * (roi.maxY - roi.minY);

end
