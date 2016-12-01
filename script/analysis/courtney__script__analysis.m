%% load in
load( 'processed.mat' );
load( 'raw.mat' );
%% specify trial parameters

separated = processed.only( {'negative', '0.5'} );

%% split into sections

separated = separated.foreach( @courtney__split_percent_per_day, [0 1] );

%   unprocessed

raw_split.excel_images = raw.excel_images.foreach( @courtney__split_percent_per_day, [0 1], { 'days' } );

%% fix psth

analyses.psth = courtney__analysis__fix_psth( separated );

%% order of target selection (patch)

orders = courtney__analysis__target_order( raw.excel_images.images );

means = targPercent( orders );

%%  order of target selection (excel)

orders = courtney__analysis__excel_target_order( raw.excel_images.labels );

targPercent( orders.data );

percentages = courtney__analysis__targ_percent_grand_mean( orders );

%% separate patch res and travel time

raw_separated = raw_split.excel_images.images.remove( { 'endbatch', 'image_state_maxed_out', 'travelbarselected' } );
patch_res = raw_separated.data(:,2) - raw_separated.data(:, 1);
travel_time = raw_separated.data(:,3);

thresh = patch_res > 100;
patch_res = patch_res( thresh, : ); travel_time = travel_time( thresh );


%% see haydens -- delay discounting / simple exponential

objects = separated.objectfields();

for i = 1:numel( objects )

    data = getdata( separated.( objects{i} ) );

    csvwrite( [objects{i} '.csv'], data );

end