function [ excel_images, excel_fields ] = courtney__process__excel_method( outerfolder )

if ( nargin == 0 )
    outerfolder = '/Volumes/My Passport/NICK/Chang Lab 2016/courtney/behavioral/data/112216';
end

%   get the excel files

excel_files = courtney__excel2obj( courtney__get_excel_files( outerfolder ) );

%   add metadata to each image presentation time

excel_images = courtney__add_trial_paramaters_to_excel_file_object( excel_files );

%   convert string travel times to numeric travel times

excel_images = courtney__string_to_numeric_travel_time( excel_images );

%   reformat string travel times

excel_images = courtney__reformat_excel_travel_times( excel_images );

%   mark what each column of <excel_images.images.data> corresponds to

excel_fields = struct();

excel_fields.data = { 'imageDisplayedTime', 'travelBarSelectedTime', 'travelDelayDuration' };


end