function fixed = courtney__remove_patch_errors( patch )

assert( isa(patch, 'DataObject'), '<patch> must be a DataObject' );

data_errors = patch.data( :, end ) == 0;
travel_errors = patch.where( 'TBerr_1' );

errors = data_errors | travel_errors;

fixed = patch( ~errors );

end