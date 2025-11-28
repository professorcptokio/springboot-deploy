package com.examplebatch.demobatch;


import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.batch.core.JobParametersBuilder;


@Configuration
public class MyRunner {

    @Bean
    public ApplicationRunner runJob(JobLauncher jobLauncher, Job simpleWritingJob) {
        return args -> jobLauncher.run(simpleWritingJob,
                new JobParametersBuilder()
                        .addLong("time", System.currentTimeMillis())
                        .toJobParameters());
    }
}

