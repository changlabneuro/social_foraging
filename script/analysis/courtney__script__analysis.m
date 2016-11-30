%% load in
load( 'processed.mat' );
load( 'raw.mat' );
%% specify trial parameters

separated = processed.only( {'negative', '0.5'} );

%% split into sections

separated = separated.foreach( @courtney__split_percent_per_day, [0 1] );

%% fix psth

analyses.psth = courtney__analysis__fix_psth( separated );

%% order of target selection

orders = courtney__analysis__target_order( raw.patch_images.images );

means = targPercent( orders );

%% see haydens -- delay discounting / simple exponential

objects = separated.objectfields();

for i = 1:numel( objects )

    data = getdata( separated.( objects{i} ) );

    csvwrite( [objects{i} '.csv'], data );

end