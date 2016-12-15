function fits = courtney__model__log_intake( measure )

fits.expression = 'b.*log(x) + shift';

fits.model = fittype( fits.expression, 'coefficients', { 'b', 'shift' } );
fits.x = 1:numel( measure );

fits.curve = fit( fits.x(:), measure(:), fits.model );

fits.b = fits.curve.b;
fits.shift = fits.curve.shift;

fits.func = @(x) fits.b .* log(x) + fits.shift;


end