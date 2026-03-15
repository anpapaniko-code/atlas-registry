package gr.atlas.registry.service;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EntityScan(basePackages = "gr.atlas.registry.domain")
@EnableJpaRepositories(basePackages = "gr.atlas.registry.service.repository")
public class CitizenRegistryServiceApplication {

	public static void main(String[] args) {
		SpringApplication.run(CitizenRegistryServiceApplication.class, args);
	}
}

