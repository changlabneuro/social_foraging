%% load in
% pathinit('court'); pathadd('court');
load( 'processed.mat' );
files = { 'events', 'images', 'labels', 'times' };

raw = struct();
raw.excel_images = struct();

for i = 1:numel( files )
    current = load( ['raw' files{i}] ); current = current.object;
    raw.excel_images.( files{i} ) = current;
end

raw.excel_images = DataObjectStruct( raw.excel_images );
raw.excel_images = courtney__add_day_labels( raw.excel_images );
processed = courtney__add_day_labels( processed );

processed = processed.replace( 'neg', 'negative' );
processed = processed.replace( 'pos', 'positive' );

% load( 'raw.mat' );

%% specify trial parameters

separated = processed.only( {'positive', 'lager'} );

%% split processed into sections

separated = separated.foreach( @courtney__split_percent_per_day, [0 1] );

%% split unprocessed into sections

raw_split.excel_images = raw.excel_images.foreach( @courtney__split_percent_per_day, [.5 1], { 'days' } );

%% fix psth

analyses.psth = courtney__analysis__fix_psth( separated, 100 );

%% separate patch res and travel time

to_split = raw_split.excel_images.images.only( {'block__valence','jodo'} );

raw_separated = to_split.remove( { 'endbatch', 'image_state_maxed_out', 'travelbarselected' } );
patch_res = raw_separated.data(:,2) - raw_separated.data(:, 1);
travel_time = raw_separated.data(:,3);

thresh = patch_res > 100;
patch_res = patch_res( thresh, : ); travel_time = travel_time( thresh );


%% save objects

goto( 'processed_data' );

objects = separated.objectfields();

ignore_fields = { 'fix_events', 'fix_psth' };

for i = 1:numel( objects )
    
    if ( any( strcmp( ignore_fields, objects{i} ) ) ); continue; end;

    data = getdata( separated.( objects{i} ) );

    csvwrite( [objects{i} '.csv'], data );

end

%% order of target selection (patch)

orders = courtney__analysis__target_order( raw.excel_images.images );

means = targPercent( orders );

%%  order of target selection (excel)

orders = courtney__analysis__excel_target_order( raw.excel_images.labels );

targPercent( orders.data );

percentages = courtney__analysis__targ_percent_grand_mean( orders );
