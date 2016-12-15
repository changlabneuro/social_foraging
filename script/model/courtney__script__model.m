%%  delay discount
separators = { 'block__valence', 'lager' };

separated = processed.only( separators );
separate_images = raw.excel_images.images.only( separators );

courtney__model__delay_discounting( separated, separate_images );

%%  mvt

separators = { 'block__valence', 'lager' };

separated = processed.only( separators );

analyses.psth = courtney__analysis__fix_psth( separated, 100 );

% analyses.fits = courtney__model__mvt( analyses.psth.summed, 'showPlots', true );
analyses.fits = courtney__model__mvt( analyses.psth.summed );

%%  sliding window slope comparison

separators = { 'block__valence', 'lager' };

separated = processed.only( separators );
separate_images = raw.excel_images.images.only( separators );

analyses.sliding_slope = courtney__analysis__sliding_window_slope( ...
    separated, separate_images, 'resolution', .1 );

ys = analyses.sliding_slope.intercepts.observed;
xs = 1:numel( ys ); xs = xs'; xs = [ones(size(xs)) xs];

%   make fractional to optimal

ys = ys / (analyses.fits.travelTime_vs_patchResidence.intercept/10);

[r, p] = corr( xs(:,2), ys(:) );
fits = xs \ ys(:);
intercept = fits(1);
slope = fits(2);

figure;
plot( xs(:,2), (xs(:,2) .* slope) + intercept ); hold on;
% plot( analyses.sliding_slope.intercepts.observed );
plot( ys );

% plot( analyses.sliding_slope.weights );
% plot( analyses.sliding_slope.slopes.observed );

%%  bootstrapped sliding slope

separated = processed.only( separators );
separate_images = raw.excel_images.images.only( separators );

analyses.bootstrap = courtney__analysis__sliding_slope_bootstrap( ...
    separated, separate_images, ...
    'sampleLevel', 'withinSessionPortion', ...
    'iterations', 20 ...
);

%%  sliding window slope per session

separators = { 'block__color_control', 'lager' };

separated = processed.only( separators );
separate_images = raw.excel_images.images.only( separators );

courtney__analysis__sliding_window_slope_per_session( separated, separate_images );
