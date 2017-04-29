function [local_migration] = migration_test_local (rank, job_id, min_idle, job_len)

global l_x;
global l_y;
global l_z;
global r_x;
global r_y;
global r_z;
global JOB_ID;
global JOB_SIZE_Q;
global JOB_TIME_Q;
global S;
global scale;
global bin_counter;
global total_bin_size;
global bin_left_size;


placed_job = zeros(1,100000);
placed_job_counter = 0;
local_migration = 0;

S_BACKUP = S;
JOB_ID_BACKUP = JOB_ID;

for z = l_z(rank) : r_z(rank)
    for x = l_x(rank) : r_x(rank)
        for y = l_y(rank) : r_y(rank)
            
            if JOB_ID(x,y,z) ~= 0
                placed_job_counter = placed_job_counter + 1; 
                placed_job(placed_job_counter) = JOB_ID(x,y,z); 
                
            end
        end
    end
end

placed_job = placed_job(find(placed_job));
placed_job = unique(placed_job);



final_id = 0;
final_idle = scale*scale*scale;
final_new_host = 0;
final_idle_victim_origin = scale*scale*scale;

for i = 1 : length(placed_job)

    for z = l_z(rank) : r_z(rank)
        for x = l_x(rank) : r_x(rank)
            for y = l_y(rank) : r_y(rank)

                if JOB_ID(x,y,z) == placed_job(i)
                    JOB_ID(x,y,z) = 0;
                    S(x,y,z,1) = 0;  
                end
            end
        end
    end

    migr_idle = one_bin_placement(rank, job_id, job_len);

    if migr_idle < scale*scale*scale
        
        victim_min_idle = scale*scale*scale; 
        new_host = 0;
        S = S_BACKUP;
        JOB_ID = JOB_ID_BACKUP;
        
        for z = l_z(rank) : r_z(rank)
            for x = l_x(rank) : r_x(rank)
             for y = l_y(rank) : r_y(rank)

                if JOB_ID(x,y,z) == placed_job(i)
                    JOB_ID(x,y,z) = 0;
                    S(x,y,z,1) = 0;  
                end
             end
            end
         end

        victim_idle_cur = one_bin_placement(rank, placed_job(i),JOB_TIME_Q(placed_job(i)));
        
        S = S_BACKUP;
        JOB_ID = JOB_ID_BACKUP;
        
        for j = 1:bin_counter
            if j ~= rank
                victim_idle = one_bin_placement(j, placed_job(i),JOB_TIME_Q(placed_job(i)));
                if victim_idle < victim_min_idle
                    victim_min_idle = victim_idle;
                    new_host = j;
                end
            end
        end

        if victim_min_idle < scale*scale*scale

            if victim_min_idle - victim_idle_cur +  migr_idle >= min_idle
                S = S_BACKUP;
                JOB_ID = JOB_ID_BACKUP;
                continue;
            else
                if victim_min_idle < final_idle
                
                 final_idle = victim_min_idle;
                 final_id = placed_job(i);
                 final_new_host =  new_host;
                 final_idle_victim_origin = victim_idle_cur;
                 JOB_ID = JOB_ID_BACKUP;
                 S = S_BACKUP;
                 continue;    
                end
                
            end
             
        else
             JOB_ID = JOB_ID_BACKUP;
             S = S_BACKUP;
             continue; 
        end
        
    else
        JOB_ID = JOB_ID_BACKUP;
        S = S_BACKUP;
        continue;    
    end 
end


JOB_ID = JOB_ID_BACKUP;
S = S_BACKUP;

if final_idle < scale*scale*scale
    for z = l_z(rank) : r_z(rank)
        for x = l_x(rank) : r_x(rank)
            for y = l_y(rank) : r_y(rank)

                if JOB_ID(x,y,z) == final_id
                    JOB_ID(x,y,z) = 0;
                    S(x,y,z,1) = 0;  
                end
            end
        end
    end
    
    idle_final_incoming = one_bin_placement(rank, job_id, job_len);
    idle_final_victim = one_bin_placement(final_new_host, final_id, JOB_TIME_Q(final_id));

    total_bin_size = total_bin_size - JOB_SIZE_Q(job_id) - idle_final_incoming - (idle_final_victim - final_idle_victim_origin);
    bin_left_size(rank) = bin_left_size(rank) - JOB_SIZE_Q(job_id) - idle_final_incoming + JOB_SIZE_Q(final_id) + final_idle_victim_origin;
    bin_left_size(final_new_host) = bin_left_size(final_new_host) - JOB_SIZE_Q(final_id) - final_idle;

    
    local_migration = 1;
    
end   
    
    
    
    


