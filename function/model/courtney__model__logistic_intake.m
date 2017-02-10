function fits = courtney__model__logistic_intake( measure )

fits.expression = '1 ./ (1 + exp(-k .* x))';
fits.expression = '(L + z) ./ (1 + exp(-k.*(x - x0)))';

% x_plot = (1:length(newBinned));
% non_adjusted = L./(1 + exp(-k.*(x_plot - x0)));
% y_shift = non_adjusted(1);
% g = @(x) (L+y_shift )./(1 + exp(-k.*(x - x0))) - y_shift;

fits.model = fittype( fits.expression, 'coefficients', { 'k', 'L', 'z', 'x0' } );
fits.x = 1:numel( measure );
% fits.x = -numel(measure):numel(measure)-1;

% max_slope = find( diff(measure) == max(diff(measure)) );
% 
% fits.x = (-numel(measure) + max_slope):numel(measure) - max_slope + 1;

% right_half = measure(max_slope:end);
% left_half = -fliplr(right_half);
% measure = [left_half right_half];

% measure = [-fliplr(measure) measure];

fits.curve = fit( fits.x(:), measure(:), fits.model );

% fits.b = fits.curve.b;
fits.k = fits.curve.k;
% fits.b = 1;
fits.L = fits.curve.L;
fits.z = fits.curve.z;
fits.x0 = fits.curve.x0;

% fits.func = @(x) fits.b ./ (1 + exp(-fits.k .* x));
fits.func = @(x) (fits.L + fits.z) ./ (1 + exp(-fits.k .* (x - fits.x0)) );




end