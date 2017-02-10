function outs = courtney__model__mvt( measure, varargin )

params = struct( ...
    'intakeFunction', 'log', ...
    'patchTimes', 0:numel(measure), ...
    'travelTimes', [10 30 50 70], ...
    'showPlots', true, ...
    'savePlots', false, ...
    'extension', 'epsc', ...
    'binnedMeasure', [], ...
    'plotSubfolder', '121916' ...
);
params = parsestruct( params, varargin );

patch_times = params.patchTimes;
travel_times = params.travelTimes;

%   get the intake function g();

switch params.intakeFunction
    case 'log'
        fits = courtney__model__log_intake( measure );
    case 'linear'
        fits = courtney__model__linear_intake( measure );
    case 'logistic'
        fits = courtney__model__logistic_intake( measure );
    case 'hyperbolic'
        fits = courtney__model__hyperbolic_intake( measure );
    otherwise
        error( 'Unrecognized intake function %s', params.intakeFunction );
end

%   for each patch residence and travel-time, obtain the 'optimal' intake
%   rate based on g();

g = fits.func;

rates = zeros( numel(patch_times), numel(travel_times) );

for i = 1:numel( patch_times )
    patch_residence = patch_times(i);
    
    gT = g( patch_residence );
    
    for j = 1:numel( travel_times )
        travel_time = travel_times(j);
        
        rates(i, j) = gT / (patch_residence + travel_time );
%         rates(i, j) = gT / patch_residence;
    end
end

%   find maximum rates per travel time

max_indices = zeros( 1, size( rates,2 ) );
max_rates = zeros( size( max_indices ) );

for i = 1:size( rates, 2 )
    [max_rates(i), max_indices(i)] = max( rates(:,i) );
end

%   calculate optimal travel time vs. patch res

optimal_patch_times = patch_times( max_indices );

X = [ ones( numel(travel_times), 1 ) travel_times(:) ];

travel_time_vs_patchResidence = X \ optimal_patch_times(:);

outs.travelTime_vs_patchResidence.intercept = travel_time_vs_patchResidence(1);
outs.travelTime_vs_patchResidence.slope =  travel_time_vs_patchResidence(2);

outs.travelTime_vs_patchResidence.travel_time = travel_times;
outs.travelTime_vs_patchResidence.rate = optimal_patch_times;    %   left in for compatability
outs.travelTime_vs_patchResidence.patch_time = optimal_patch_times;

if ( ~params.showPlots ); return; end;

savepath = fullfile( pathfor('plots'), params.plotSubfolder );
extension = params.extension;

%   plot raw binned look counts, if they exist

if ( ~isempty(params.binnedMeasure) )
    figure;
    plot( params.binnedMeasure );
    fix_tick( 'xticklabel' );
    xlabel( 'Time (s)' );
    ylabel( 'Fixation counts: summed over trials, binned into 100ms bins' );
    filename = fullfile( savepath, 'binned_looking_behavior' );
    saveas( gcf, filename, extension );
end


%   comparison between fitted + observed

figure; hold on;
plot( g( patch_times ) );
plot( measure );
legend( {'Approximated', 'Observed'} );
ylabel( 'Social reward harvested' ); fix_tick( 'xticklabel' );

if ( params.savePlots )
    filename = fullfile( savepath, 'gT_vs_observed' );
    saveas(gcf, filename, extension );
end

%   patch-res vs. max intake rate, per travel time

figure; hold on;
plot( rates );
plot( max_indices, max_rates, 'k', 'linewidth', 2 );
legend__tts = cell( size( travel_times ) );
for i = 1:numel(travel_times), legend__tts{i} = num2str( travel_times(i)/10 ); end;
legend( legend__tts );
fix_tick( 'xticklabel' ); xlabel( 'Time (s)' ); ylabel( 'E_n' );
ylim( [0, max( max_rates(:) )] );

if ( params.savePlots )
    filename = fullfile( savepath, 'energy_intake_vs_patch_res' );
    saveas(gcf, filename, extension );
end

%   travel time vs. rate-maximizing patch-res time

figure; hold on;
plot( travel_times, optimal_patch_times );
xlim([0 max(travel_times) + 10]);
ylim([0 max(optimal_patch_times)+5]);
fix_tick( 'yticklabel' );
fix_tick( 'xticklabel' );
xlabel( 'Travel Time' );
ylabel( 'Patch Residence Time' );


end

function fix_tick(type)

if ( nargin < 1 ), type = 'xticklabel'; end;

labels = get(gca, type );
nums = str2double( labels );
nums = nums / 10;
for i = 1:numel( nums )
    labels{i} = num2str( nums(i) );
end

set(gca, type, labels );

end
