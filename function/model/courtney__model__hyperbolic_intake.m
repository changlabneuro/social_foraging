function fits = courtney__model__hyperbolic_intake( measure )

fits.expression = 'b./(1+k.*x)';

fits.model = fittype( fits.expression, 'coefficients', { 'b', 'k' } );
fits.x = 1:numel( measure );

fits.curve = fit( fits.x(:), measure(:), fits.model );

fits.b = fits.curve.b;
fits.k = fits.curve.k;

fits.func = @(x) fits.b ./ (1+fits.k .* x );


end