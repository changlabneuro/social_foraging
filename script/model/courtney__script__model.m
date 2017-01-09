%%  delay discount

% separators = { 'block__valence', 'lager' };
% separators = { 'block__valence', 'block__color_control' };
separators = { 'block__social' };

% separate_images = raw.excel_images.images.only( separators );

separated = processed.only( separators );
separate_images = separated.images;

filenames.mvt = fullfile( pathfor('plots'), '010307/model/mvt/social' );
filenames.discount = fullfile( pathfor('plots'), '010307/model/discount/social' );

[analyses.fits.mvts, analyses.fits.discount] = ...
  courtney__model__delay_discounting( separated, separate_images, ...
    'mvtYLims', [-8 8], ...
    'SAVE', true, ...
    'filenames', filenames ...
  );

analyses.aics.aic = cellfun( @(x) x.mdl.ModelCriterion.AIC, analyses.fits.mvts );
analyses.aics.tt = cellfun( @(x) x.travel_time, analyses.fits.mvts );

%%  mvt

separators = { 'block__social', 'nonsocial' };
% separators = { 'block__valence', 'block__color_control', 'positive' };
% separators = { 'block__social', 'lager', 'expression__na' };

separated = processed.only( separators );

analyses.psth = courtney__analysis__fix_psth( separated, 100 );
    
analyses.fits = courtney__model__mvt( analyses.psth.summed, ...
  'binnedMeasure', analyses.psth.binned, ...
  'savePlots', false, ...
  'showPlots', true, ...
  'plotSubfolder', '121916/social_control/social' );

%%  1c

% separators = { 'block__social', 'nonsocial' };
% separators = { 'block__valence', 'block__color_control', 'neg' };
% separators = { 'block__valence', 'block__color_control' };
separators = { 'block__social', 'nonsocial' };
% separators = { 'block__valence', 'block__color_control', 'negative' };

% separate_images = raw.excel_images.images.only( separators );
separate_images = processed.images.only( separators );

analyses.fits.tt_observed = courtney__analysis__tt_v_patchres( ...
    separate_images, analyses.fits.travelTime_vs_patchResidence, ...
    'maxPatchTime', 15e3 );

courtney__plot__observed_and_optimal_travel_time_vs_patch_res( ...
    analyses.fits.tt_observed, ...
    'yLimits', [0 5], ...
    'savePlot', false, ...
    'plotModeled', true, ...
    'title', [], ...
    'plotSubfolder', '121916/valence/negative' );

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
