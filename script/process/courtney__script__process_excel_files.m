%% excel file method

outerfolder = '/Volumes/My Passport/NICK/Chang Lab 2016/courtney/behavioral/data/112216';

e.excel_images = courtney__process__excel_method( outerfolder );

%   get the excel files

e.excel_files = courtney__excel2obj( courtney__get_excel_files( outerfolder ) );

%   add metadata to each image presentation time

e.excel_images = courtney__add_trial_paramaters_to_excel_file_object( e.excel_files );

%   convert string travel times to numeric travel times

e.excel_images = courtney__string_to_numeric_travel_time( e.excel_images );

%   reformat string travel times

e.excel_images = courtney__reformat_excel_travel_times( e.excel_images );

%% output patch files

% outerfolders.patch = '/Volumes/My Passport/NICK/Chang Lab 2016/courtney/behavioral/data/092316/outputpatchfiles';

outerfolders.patch = '/Volumes/My Passport/NICK/Chang Lab 2016/courtney/behavioral/archive/social_control_data/patch_files';
outerfolders.excel = '/Volumes/My Passport/NICK/Chang Lab 2016/courtney/behavioral/archive/social_control_data/excel_files';

%   load in files

[e.patches, e.patch_fields] = patch2obj( outerfolders.patch );

e.excel_files = courtney__cell_files_to_object_files( getFiles( outerfolders.excel ) );

%   remove errors

e.patches = courtney__remove_patch_errors( e.patches );

%   convert matlab time -> eyelink time

e.patches = courtney__convert_to_eyelink_time( e.patches, e.excel_files, e.patch_fields );

%   store as patch_images

e.excel_files.images = e.patches;
e.patch_images = e.excel_files;

e.patch_images = courtney__add_string_travel_time( e.patch_images, e.patch_fields );

%% process

e.patch_image_data = courtney__fix_event_data( e.patch_images, e.patch_fields );
e.excel_image_data = courtney__fix_event_data( e.excel_images, e.excel_fields );

%% cleanup & combine

e.patch_image_data = courtney__add_day_labels( e.patch_image_data );
e.excel_image_data = courtney__add_day_labels( e.excel_image_data );

e.patch_image_data = e.patch_image_data.addfield( 'fileType' );
e.excel_image_data = e.excel_image_data.addfield( 'fileType' );

e.patch_image_data = e.patch_image_data.setfield( 'fileType', 'patch' );
e.excel_image_data = e.excel_image_data.setfield( 'fileType', 'excel' );

image_data = e.patch_image_data.perfield( e.excel_image_data, @append );

%%


