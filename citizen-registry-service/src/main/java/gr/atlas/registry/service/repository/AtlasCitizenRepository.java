package gr.atlas.registry.service.repository;

import gr.atlas.registry.domain.AtlasCitizen;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;


@Repository
public interface AtlasCitizenRepository
        extends JpaRepository<AtlasCitizen, String>,
        JpaSpecificationExecutor<AtlasCitizen> {
}