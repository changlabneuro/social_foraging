function courtney__analysis__sliding_window_slope_per_session( processed, images, resolution )

if ( nargin < 3 ), resolution = .1; end;

sessions = images.uniques( 'sessions' );

sliding_slopes = cell( 1, numel(sessions) );

bins = 1 / resolution;

for i = 1:numel( sessions )
    
    separate_processed = processed.only( sessions{i} );
    separate_images = images.only( sessions{i} );

    sliding_slopes{i} = courtney__analysis__sliding_window_slope( ...
        separate_processed, separate_images, 'resolution', resolution );

end

intercepts = cellfun( @(x) x.intercepts.observed, sliding_slopes, 'UniformOutput', false );
figure; hold on;
cellfun( @(x) plot(x), intercepts );

% cellfun( @(x) scatter(1:numel(x), x), intercepts );

matrix = zeros( numel(sessions), bins );

for i = 1:numel( sessions )
    matrix(i,:) = intercepts{i};
end

errors = sum( isinf(matrix), 2 ) >= 1; matrix(errors,:) = [];

end

