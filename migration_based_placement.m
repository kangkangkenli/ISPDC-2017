function migration_based_placement (job_id, job_len)

global S;
global JOB_ID;
global scale;
global FLAG;
global bin_counter;
global total_bin_size;
global bin_left_size;
global JOB_SIZE_Q;


idle = ones(1,bin_counter)* (scale*scale*scale);
internal_frag = ones(1,bin_counter)* (scale*scale*scale);


S_BACKUP = S;
JOB_ID_BACKUP = JOB_ID;


for bin_num = 1: bin_counter        
        
    [idle(bin_num), internal_frag(bin_num)] = one_bin_placement(bin_num, job_id, job_len);
        
end
    
[min_idle,index] = min(idle);

if min_idle < scale*scale*scale
     
    [internal_frag, rank] = sort(internal_frag);

    
    for i = 1:bin_counter
        
        if idle(rank(i)) < scale*scale*scale
            
            S = S_BACKUP;
            JOB_ID = JOB_ID_BACKUP;
            
            idle_final = one_bin_placement(rank(i), job_id, job_len);
            total_bin_size = total_bin_size - JOB_SIZE_Q(job_id) - idle(rank(i));
            bin_left_size(rank(i)) = bin_left_size(rank(i)) - JOB_SIZE_Q(job_id) - idle(rank(i));
            FLAG(job_id) = 1;
            break;

        else
            
            S = S_BACKUP;
            JOB_ID = JOB_ID_BACKUP;
            
            migration_flag = migration_test_local(rank(i),job_id,min_idle,job_len);
            
            if migration_flag == 1
                FLAG(job_id) = 1;
                break;
            
             else
                 continue;
            end
         
         end
     end
    
else
    
   FLAG(job_id) = 0;
   
end    


    
