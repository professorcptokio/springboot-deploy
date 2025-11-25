package com.examplebatch.demobatch;

import java.io.FileWriter;
import java.io.IOException;
import java.time.LocalDateTime;



import com.cptokio.mybatch.domain.Product;
import com.cptokio.mybatch.processors.ProductItemProcessor;
import com.cptokio.mybatch.repository.ProductRepository;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.batch.item.data.RepositoryItemWriter;
import org.springframework.batch.item.file.FlatFileItemReader;
import org.springframework.batch.item.file.mapping.DefaultLineMapper;
import org.springframework.batch.item.file.transform.DelimitedLineTokenizer;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.transaction.PlatformTransactionManager;

@Configuration
public class BatchConfig {

    @Value("${output.file:./batch_output.txt}")
    private String outputFilePath;


    @Bean
    public Tasklet fileWritingTasklet() {
        return (contribution, chunkContext) -> {
            // Obtém o timestamp atual para tornar o conteúdo único
            String content = "Execução do Batch em: " + LocalDateTime.now() + "\n";
            
            // Escreve o conteúdo no arquivo (modo append 'true')
            try (FileWriter fw = new FileWriter(outputFilePath, true)) {
                fw.write(content);
                System.out.println("Conteúdo escrito em: " + outputFilePath);
            } catch (IOException e) {
                System.err.println("Erro ao escrever o arquivo: " + e.getMessage());
                throw e; // Lança exceção para falhar o step/job
            }
            
            // Retorna o status de conclusão do step
            return org.springframework.batch.repeat.RepeatStatus.FINISHED;
        };
    }


    @Bean
    public Step writeToFileStep(JobRepository jobRepository, PlatformTransactionManager transactionManager) {
        return new StepBuilder("writeToFileStep", jobRepository)
                .tasklet(fileWritingTasklet(), transactionManager) // Usa a lógica definida acima
                .build();
    }

    @Bean
    public Job simpleWritingJob(JobRepository jobRepository, Step writeToFileStep) {
        return new JobBuilder("simpleWritingJob", jobRepository)
                .start(writeToFileStep) 
                .build();
    }

}
