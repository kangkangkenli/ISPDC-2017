function [migration_success] = migration_test(job_id)

global S;
global JOB_ID;
global scale;
global cur_job;
global FLAG;
global JOB_TIME_Q;
global JOB_SIZE_Q;

running_job_list = get_running_job_id();
sort(running_job_list);

migr_running_job_list = zeros(1, length(running_job_list));
migr_count = 0;

thres = 0;

if JOB_SIZE_Q(job_id) >= 1000 && JOB_SIZE_Q(job_id) <= 1500 
    thres = 500;
elseif JOB_SIZE_Q(job_id) > 500 && JOB_SIZE_Q(job_id) < 1000 
    thres = 100;
    
elseif JOB_SIZE_Q(job_id) >= 100 && JOB_SIZE_Q(job_id) <= 500 
    thres = 75;
    
end


for i = 1: length(running_job_list)
    if JOB_SIZE_Q(running_job_list(i)) <= thres
        migr_count = migr_count + 1;
        migr_running_job_list(migr_count) = running_job_list(i);
    end
end

migr_running_job_list = migr_running_job_list(find(migr_running_job_list));



migr_running_job_remaining_time = zeros(1, length(migr_running_job_list));



for i = 1: length(migr_running_job_list)
    migr_running_job_remaining_time(i) = get_running_job_remaining_time(migr_running_job_list(i));
end


for i = 1: length(migr_running_job_list)
    FLAG(migr_running_job_list(i)) = 0;
end
 
migration_input_job_num = length(migr_running_job_list) + 1;


migration_job_list = [migr_running_job_list cur_job];
migration_job_time = [migr_running_job_remaining_time JOB_TIME_Q(cur_job)];


SYS_BACKUP = S;
JOB_ID_BACKUP = JOB_ID;

for i = 1:length(migr_running_job_list)
    for z = 1:scale
        for x = 1:scale
            for y = 1:scale
                if JOB_ID(x,y,z) == migration_job_list(i)
                    JOB_ID(x,y,z) = 0;
                    S(x,y,z,1) = 0;
                end
            end
        end
    end
end


free_partition_detection();

input_counter = 0;



for i = 1 : migration_input_job_num
    
        migr_cur_job_id = migration_job_list(i);
        migr_cur_job_time = migration_job_time(i);

        normal_allocation(migr_cur_job_id, migr_cur_job_time);

        
             if FLAG(migr_cur_job_id) == 1
                 input_counter = input_counter + 1;
             else
                 
                 migration_success = 0;
                 
                 S = SYS_BACKUP;
                 JOB_ID = JOB_ID_BACKUP;
                for j = 1: length(migr_running_job_list)
                  FLAG(migr_running_job_list(j)) = 1;
                end
                
                 break;
                 
             end
end

if input_counter == migration_input_job_num
    migration_success = 1;

end

  
    