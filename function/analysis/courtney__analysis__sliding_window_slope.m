function outs = courtney__analysis__sliding_window_slope( measures, images, varargin )

params = struct( ...
    'resolution', .1, ...
    'fastestViewTime', 2.4, ...
    'optimalViewTime', .2, ...
    'bootstrap', false ...
    );
images = images.remove( { 'endbatch', 'image_state_maxed_out', 'travelbarselected' } );

params = parsestruct( params, varargin );

resolution = params.resolution;

N = 1 / resolution;

weights = zeros( 1, N ); slopes = cell( 1, N ); intercepts = cell( 1, N ); 
aucs = cell( 1, N );

bounds = zeros( 1, 2 );

for i = 1:N
    
    bounds(2) = i * resolution;
    
    split_images = courtney__split_percent_per_day( ...
        images, bounds, { 'days' } );
    split_measures = measures.foreach( @courtney__split_percent_per_day, ...
        bounds );
    
    if ( params.bootstrap )
        split_images = do_resampling( split_images );
        split_measures = split_measures.foreach( @do_resampling );
    end
    
    [ weights(i), slopes{i}, intercepts{i}, aucs{i} ] = ...
        one_comparison( split_measures, split_images, params );
    
    bounds(1) = bounds(2);
    
end

outs.weights = weights;

outs.slopes.optimal = cellfun( @(x) x.optimal, slopes );
outs.slopes.observed = cellfun( @(x) x.observed, slopes );

outs.intercepts.optimal = cellfun( @(x) x.optimal, intercepts );
outs.intercepts.observed = cellfun( @(x) x.observed, intercepts );

outs.aucs.optimal = cellfun( @(x) x.optimal, aucs );
outs.aucs.observed = cellfun( @(x) x.observed, aucs );

end

function [weight, slopes, intercepts, aucs] = one_comparison( fix_psth, images, params )

view_time = params.optimalViewTime;

%   'optimal'

psth = courtney__analysis__fix_psth( fix_psth, 100 );

optimal = courtney__model__mvt( psth.summed, 'showPlots', false );

optimal_slope = optimal.travelTime_vs_patchResidence.slope;
optimal_intercept = optimal.travelTime_vs_patchResidence.intercept;
optimal_traveltimes = optimal.travelTime_vs_patchResidence.travel_time;

regression_function = @(x) x.*optimal_slope + optimal_intercept;
aucs.optimal = integral( regression_function, optimal_traveltimes(1), optimal_traveltimes(end) );

%   observed

patch_res = images.data(:,2) - images.data(:, 1);
travel_time = images.data(:,3);
travel_times = unique( travel_time );

thresh = patch_res > 100;
patch_res = patch_res( thresh, : ); travel_time = travel_time( thresh );

%   match units

patch_res = patch_res / 1000;

%   account for juice reward

adjusted = repmat( view_time, size( patch_res ) );
patch_res = mean( [patch_res adjusted], 2 );

travel_time = [ ones(numel(travel_time), 1) travel_time ];

fit = travel_time \ patch_res;
observed_slope = fit(2);
observed_intercept = fit(1);

%   test auc

regression_function = @(x) x.*observed_slope + observed_intercept;
aucs.observed = integral( regression_function, travel_times(1), travel_times(end) );

weight = observed_slope / optimal_slope;

slopes.optimal = optimal_slope;
slopes.observed = observed_slope;

intercepts.observed = observed_intercept;
intercepts.optimal = optimal_intercept;

end


function obj = do_resampling( obj )

obj.data = datasample( obj.data, size(obj.data, 1) );

end