BLOCK = 'valence';
VALENCE = 'neg';

%%  delay discount

separators = { ['block__' BLOCK] };
% separators = { 'block__social' };

% separate_images = raw.excel_images.images.only( separators );

separated = processed.only( separators );
separate_images = separated.images;

filenames.mvt = fullfile( pathfor('plots'), ['042017/model/mvt/' BLOCK] );
filenames.discount = fullfile( pathfor('plots'), ['042017/model/discount/' BLOCK] );
filenames.combined = fullfile( pathfor('plots'), ['042017/model/combined/' BLOCK] );

[analyses.fits.mvts, analyses.fits.discount] = ...
  courtney__model__delay_discounting( separated, separate_images, ...
    'showPlots', true, ...
    'mvtYLims', [-.0005 .1], ...
    'SAVE', false, ...
    'filenames', filenames ...
  );

analyses.aics.aic = cellfun( @(x) x.mdl.ModelCriterion.AIC, analyses.fits.mvts );
analyses.aics.tt = cellfun( @(x) x.travel_time, analyses.fits.mvts );
%%  MODEL SUMMARY

tbls = courtney__model__summary( analyses.fits.discount, analyses.fits.mvts );
mvt_fit_tbl = courtney__model__coefficient_summary( analyses.fits.mvts );

filename = fullfile( pathfor('analyses'), '012817', 'tables', BLOCK );
fs = fieldnames(tbls);
for i = 1:numel(fs)
  writetable( tbls.(fs{i}), fullfile(filename, [fs{i} '__table.csv']) );
end

writetable( mvt_fit_tbl, fullfile(filename, [fs{i} '__regression_table.csv']) );

%% PLOT AIC
aics = courtney__model__get_aic( analyses.fits.discount, analyses.fits.mvts );
weights = courtney__model__get_ak_weights( aics );
%   plot aics
courtney__plot__aic( aics, ...
  'savePath', fullfile(pathfor('plots'), ['011817/model/aics/whole_session/' BLOCK]), ...
  'SAVE', false, 'yAxisLocation', 'right', 'yLim', [-1160, -1040] );
%%   plot weights
courtney__plot__ak_weights( weights, aics, ... 
  'savePath', fullfile(pathfor('plots'), ['011817/model/weights/whole_session/' BLOCK]), ...
  'SAVE', true, 'plotRelative', true );

%% PLOT AIC DIFFERENCE OVER TIME

[aics, weights] = courtney__model__aic_difference_over_time( separated );
courtney__plot__aic_over_time( aics, ...
  'savePath', fullfile(pathfor('plots'), ['011817/model/aics/over_time/' BLOCK]), ...
  'SAVE', false );
courtney__plot__ak_weights_over_time( weights, aics, ...
  'savePath', fullfile(pathfor('plots'), ['011817/model/weights/over_time/' BLOCK]), ...
  'SAVE', true );


%%  mvt

% separators = { 'block__social', 'nonsocial' };
% separators = { 'block__valence', 'block__color_control' };
% separators = { 'block__valence', 'block__color_control' };
% separators = { 'block__valence', 'block__color_control', 'jodo' };
% separators = { 'block__social', 'lager', 'expression__na' };

separated = processed.only( separators );

analyses.psth = courtney__analysis__fix_psth( separated, 100 );
    
analyses.fits = courtney__model__mvt( analyses.psth.summed, ...
  'intakeFunction', 'log', ...
  'binnedMeasure', analyses.psth.binned, ...
  'savePlots', false, ...
  'showPlots', true, ...
  'plotSubfolder', '011217/fig1/valence' );

%%  new intake f(x)

analyses.psth = courtney__analysis__look_proportion( separated.proportion, 100 );
figure;
plot( abs(1-analyses.psth.binned) );
figure;
plot( -diff(analyses.psth.binned) );

%%  1c

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
    'addSEM', false, ...
    'title', [], ...
    'plotSubfolder', '121916/valence/negative' );
%% REPLICATE 

separators = { ['block__' BLOCK], VALENCE };
% separators = { ['block__' BLOCK] };
separated = processed.only( separators );

separated = separated.collapse( 'monkey' );

monks = separated.images.uniques( 'monkey' );
sep = separated.images;
psths = DataObject();
for i = 1:numel(monks)
  labels.monkeys = monks(i);
  current = separated.only( monks{i} );
  data = courtney__analysis__fix_psth( current, 100 );
  data = courtney__model__mvt( data.summed, ...
    'intakeFunction', 'log', 'binnedMeasure', data.binned, ...
    'savePlots', false, 'showPlots', false ...
  );
  psths = psths.append( DataObject( {data}, labels ) );
end

stats = courtney__plot__replicate_manuscript_fig3( sep.remove({'0.5', '9'}), ...
  'modeled', psths, 'allOnOneFigure', true, ...
  'addRibbon', true, 'save', false, ...
  'append', '_social' );

filename = fullfile( pathfor('analyses'), '012817', 'tables', BLOCK );
filename = fullfile( filename, VALENCE );
writetable( stats.data, filename );

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
