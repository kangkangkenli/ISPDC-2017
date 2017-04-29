function main()
global CAL;
CAL = 194480;
global ALLOC;
ALLOC = 0;
global TIME;
TIME = 0;
global FLAG; 
FLAG = zeros(1,CAL);

global scale;
scale = 24;
global cycle;
cycle = 15;
global UTL;
UTL= zeros(1,CAL);
global backfill_thres;
backfill_thres = 50;

global JOB_SIZE_Q;
global JOB_TIME_Q;
global T;
global N;
global T_1;
global N_1;



data();

JOB_SIZE_Q = N_1;
JOB_TIME_Q = T_1;

for i = 1: 96
    JOB_SIZE_Q = [JOB_SIZE_Q,N];
    JOB_TIME_Q = [JOB_TIME_Q,T];

end

global JOB_ID;
global S;

JOB_ID = zeros(scale,scale,scale);
S = zeros(scale,scale,scale,3);

global cur_job;
cur_job = 1;

global migration_call;
migration_call = 0;
global migration_call_job_size;
migration_call_job_size = zeros(1,2015);

global migration_success_number;
migration_success_number = 0;
global migration_success_job_size;
migration_success_job_size = zeros(1,2015);

global migration_fail_num;
migration_fail_num = 0;
global migration_fail_job_size;
migration_fail_job_size = zeros(1,2015);

global backfill_number;
backfill_number = 0;
global backfill_job_size;
global backfill_start_run_time;
global backfill_orig_time;
global backfill_delay;
backfill_job_size = zeros(1,2015);
backfill_start_run_time = zeros(1,2015);
backfill_orig_time = zeros(1,2015);
backfill_delay = zeros(1,2015);

global large_job;
large_job = zeros(1,2015);
global buffer_size;
buffer_size = 1000;
global cur_head;

for i = 1:length(N)
    if N(i) >= 50
     large_job(i) = N(i);
     
    end
end

large_job = large_job(find(large_job));



    
free_partition_detection();

S(:,:,:,3) = S(:,:,:,2);

while ALLOC <= 1520 && cur_job <= 1520

    
    first_bin_placement(1,cur_job,JOB_TIME_Q(cur_job));

    if FLAG(cur_job) == 1
        ALLOC = ALLOC + 1; 
        cur_job = cur_job + 1; 
    else
        break;
    end

end


while cur_job <= 1520+2010

 cur_head = cur_job;
 
    while cur_job <= min(cur_head + buffer_size, 1520+2010)
     if mod(TIME,cycle) == 0
        
        free_partition_detection();
        
        job_allocation_session();

     end
     system_queue_update();
    
    end   
end

backfill_job_size = backfill_job_size(find(backfill_job_size));
backfill_start_run_time = backfill_start_run_time(find(backfill_start_run_time));
backfill_orig_time = backfill_orig_time(find(backfill_orig_time));
backfill_delay = backfill_delay(find(backfill_delay));
migration_fail_job_size = migration_fail_job_size(find(migration_fail_job_size));
migration_success_job_size = migration_success_job_size(find(migration_success_job_size));
migration_call_job_size = migration_call_job_size(find(migration_call_job_size));


       
end               
               
               
               
            