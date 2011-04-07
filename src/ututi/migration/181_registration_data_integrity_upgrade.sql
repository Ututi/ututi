alter table user_registrations add constraint registration_data_integrity
    check ((location_id is null and email is not null) or
           (location_id is not null and (email is not null or facebook_id is not null)));;
