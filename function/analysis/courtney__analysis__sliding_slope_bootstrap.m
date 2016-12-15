function outs = courtney__analysis__sliding_slope_bootstrap( processed, images, varargin )

params = struct( ...
    'iterations', 10, ...
    'resolution', .1, ...
    'sampleLevel', 'withinSessionPortion' ...
);
params = parsestruct( params, varargin );

errors = { 'endbatch', 'image_state_maxed_out', 'travelbarselected' };

images = images.remove( errors );
processed = processed.remove( errors );

greater_than_zero = false( 1, params.iterations );
slopes = zeros( size( greater_than_zero ) );

for i = 1:params.iterations
    
    switch params.sampleLevel
        case 'withinSessionPortion'
            bootstrap_in_sliding_window = true;
            resampled_processed = processed; resampled_images = images;
        case 'acrossSession'
            bootstrap_in_sliding_window = false;
            resampled_processed = processed.foreach( @do_resampling );
            resampled_images = do_resampling( images );
        otherwise
            error( 'Unrecognized sampleLevel ''%s''', params.sampleLevel );
    end
    
    sliding_slope = courtney__analysis__sliding_window_slope( ...
        resampled_processed, resampled_images, ...
        'resolution', params.resolution, ...
        'bootstrap', bootstrap_in_sliding_window );
    
    close all;
    
    slopes(i) = get_slope( sliding_slope );
    greater_than_zero(i) = slopes(i) > 0;
end

fraction = sum(greater_than_zero) / numel(greater_than_zero);

outs.fraction = fraction;
outs.slopes = slopes;

end

function slope = get_slope( sliding_slope )

ys = sliding_slope.intercepts.observed;
xs = 1:numel( ys ); xs = xs'; xs = [ones(size(xs)) xs];

fits = xs \ ys(:);

slope = fits(2);


end

function obj = do_resampling( obj )

obj.data = datasample( obj.data, size(obj.data, 1) );

end