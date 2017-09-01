function p = courtney__model__intercept_permutation_test( images, sel1, sel2, field, n_perms )

thresh1 = .1;
thresh2 = 5;

if ( ~isa(images, 'Container') )
  images = Container.from( images );
  images = images.full();
end

error_tts = { 'endbatch', 'image_state_maxed_out', 'travelbarselected' };

images = images.rm( error_tts );

patchres = ( images.data(:, 2) - images.data(:, 1) ) / 1e3;
tt = images.data(:, 3);

images.data = [ patchres, tt ];

images = images.keep( patchres > thresh1 & patchres <= thresh2 );

real_difference = get_difference( images, sel1, sel2 );

was_greater = false( 1, n_perms );

for i = 1:n_perms
  fprintf( '\n %d of %d', i, n_perms );
  images_ = images;
  specifiers = images_.full_fields( field );
  specifiers = specifiers( randperm(numel(specifiers)) );
  images_( field ) = specifiers;
  difference = get_difference( images_, sel1, sel2 );
  was_greater(i) = difference > real_difference;
end

p = sum( was_greater ) / n_perms;

end

function difference = get_difference( images, sel1, sel2 )

img1 = images.only( sel1 );
img2 = images.only( sel2 );

assert( ~isempty(img1) && ~isempty(img2), 'No matching data.' );

fit1 = polyfit( img1.data(:, 2), img1.data(:, 1), 1 );
fit2 = polyfit( img2.data(:, 2), img2.data(:, 1), 1 );

int1 = fit1(1);
int2 = fit2(1);

difference = int1 - int2;

end