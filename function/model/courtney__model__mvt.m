function outs = courtney__model__mvt( measure, varargin )

params = struct( ...
    'intakeFunction', 'log', ...
    'patchTimes', 0:numel(measure), ...
    'travelTimes', [10 30 50 70], ...
    'showPlots', true ...
);
params = parsestruct( params, varargin );

patch_times = params.patchTimes;
travel_times = params.travelTimes;

%   get the intake function g();

switch params.intakeFunction
    case 'log'
        fits = courtney__model__log_intake( measure );
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

%   comparison between fitted + observed

figure; hold on;
plot( g( patch_times ) );
plot( measure );
legend( {'Approximated', 'Observed'} );

%   patch-res vs. max intake rate, per travel time

figure; hold on;
plot( rates );
plot( max_indices, max_rates, 'k', 'linewidth', 2 );
fix_tick( 'xticklabel' ); xlabel( 'Time (s)' ); ylabel( 'E_n' );
ylim( [0, max( max_rates(:) )] );

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