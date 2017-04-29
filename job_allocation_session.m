function job_allocation_session()


global ALLOC;
global FLAG; 
global JOB_SIZE_Q;
global JOB_TIME_Q;
global migration_success_number;
global backfill_number;
global migration_call;
global backfill_thres;
global MIGRATION_SUCCESS;
global cur_job;
global total_bin_size;
global UTL;

global migration_call_job_size;
global migration_success_job_size;
global migration_fail_num;
global migration_fail_job_size;
global backfill_job_size;
global cur_head;
global buffer_size;

        
while 1 > 0 && cur_job <= min(cur_head + buffer_size, 1520+2010)

  if FLAG(cur_job) == 0     
           normal_allocation(cur_job,JOB_TIME_Q(cur_job));
           
           if FLAG(cur_job) == 1
               

               ALLOC = ALLOC + 1;
              
               cur_job = cur_job + 1;
               
           elseif FLAG(cur_job) == 0 && JOB_SIZE_Q(cur_job) < backfill_thres
               
               break;
               
               
           elseif FLAG(cur_job) == 0 && JOB_SIZE_Q(cur_job) >= backfill_thres

             if JOB_SIZE_Q(cur_job) > total_bin_size  
                 system_queue_update();
                 while UTL(length(UTL)) >= 90
                  
                  system_queue_update();
                  
                 end
               free_partition_detection();    

              if total_bin_size < JOB_SIZE_Q(cur_job)                 
                   backfill_number = backfill_number + 1;
                   backfill_job_size(backfill_number) = JOB_SIZE_Q(cur_job);
                   backfill_allocation(cur_job);
                     
              else
               migration_call = migration_call + 1;
               migration_call_job_size(migration_call) = JOB_SIZE_Q(cur_job) ;
               MIGRATION_SUCCESS = migration_test(cur_job);
               if MIGRATION_SUCCESS == 1
                   migration_success_number = migration_success_number + 1;
                   migration_success_job_size(migration_success_number) = JOB_SIZE_Q(cur_job);
                   cur_job = cur_job + 1;
      
               else
                   migration_fail_num = migration_fail_num + 1;
                   migration_fail_job_size(migration_fail_num) = JOB_SIZE_Q(cur_job);
                   backfill_number = backfill_number + 1;
                   backfill_job_size(backfill_number) = JOB_SIZE_Q(cur_job);
                   backfill_allocation(cur_job);
      
               end  
               
              end 
              
             else   

               migration_call = migration_call + 1;
               migration_call_job_size(migration_call) = JOB_SIZE_Q(cur_job) ;
               MIGRATION_SUCCESS = migration_test(cur_job);
               if MIGRATION_SUCCESS == 1
                   migration_success_number = migration_success_number + 1;
                   migration_success_job_size(migration_success_number) = JOB_SIZE_Q(cur_job);
                   cur_job = cur_job + 1;
      
               else
 

                   migration_fail_num = migration_fail_num + 1;
                   migration_fail_job_size(migration_fail_num) = JOB_SIZE_Q(cur_job);
                   backfill_number = backfill_number + 1;
                   backfill_job_size(backfill_number) = JOB_SIZE_Q(cur_job);
                   backfill_allocation(cur_job);
      
               end   
             end
           end
           
   else

      cur_job = cur_job + 1 ;    
  
   end

end
