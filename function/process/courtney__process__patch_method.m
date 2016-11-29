function [ patches, fields ] = courtney__process__patch_method( outerfolder )

if ( nargin == 0 )
    outerfolder = '/Volumes/My Passport/NICK/Chang Lab 2016/courtney/behavioral/archive/social_control_data';
end

patch_directory = fullfile( outerfolder, 'fixed_patch_files' );
excel_directory = fullfile( outerfolder, 'excel_files' );

allfiles = getFiles( excel_directory );

store_patches = reformat_patch( patch_directory );

[ objects, patch_fields ] = courtney__fixed_patches_to_obj( store_patches, allfiles.ids );

excel_files = courtney__cell_files_to_object_files( getFiles( excel_directory ) );

%   convert matlab time -> eyelink time

fields.data = patch_fields;

excel_files.images = courtney__convert_to_eyelink_time( objects, excel_files, fields );

patches = excel_files;

end