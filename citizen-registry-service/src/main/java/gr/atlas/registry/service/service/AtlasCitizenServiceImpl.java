package gr.atlas.registry.service.service;

import gr.atlas.registry.domain.AtlasCitizen;
import gr.atlas.registry.service.exception.CitizenAlreadyExistsException;
import gr.atlas.registry.service.exception.CitizenNotFoundException;
import gr.atlas.registry.service.repository.AtlasCitizenRepository;
import gr.atlas.registry.service.specification.AtlasCitizenSpecification;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AtlasCitizenServiceImpl implements AtlasCitizenService {

    private final AtlasCitizenRepository repository;

    public AtlasCitizenServiceImpl(AtlasCitizenRepository repository) {
        this.repository = repository;
    }

    @Override
    public AtlasCitizen createCitizen(AtlasCitizen citizen) {

        if (repository.existsById(citizen.getAt())) {
            throw new CitizenAlreadyExistsException(citizen.getAt());
        }

        return repository.save(citizen);
    }

    @Override
    public void deleteCitizen(String at) {

        if (at == null || at.isBlank()) {
            throw new IllegalArgumentException("Invalid AT");
        }

        if (!repository.existsById(at)) {
            throw new CitizenNotFoundException(at);
        }

        repository.deleteById(at);
    }

    @Override
    public AtlasCitizen updateCitizen(String at, String afm, String address) {

        AtlasCitizen citizen = repository.findById(at)
                .orElseThrow(() -> new CitizenNotFoundException(at));

        if (afm != null) {
            citizen.setAfm(afm);
        }

        if (address != null) {
            citizen.setAddress(address);
        }

        return repository.save(citizen);
    }

    @Override
    public AtlasCitizen getCitizen(String at) {

        return repository.findById(at)
                .orElseThrow(() -> new CitizenNotFoundException(at));
    }


    @Override
    public List<AtlasCitizen> search(String at,
                                     String firstName,
                                     String lastName,
                                     String gender,
                                     String afm) {

        Specification<AtlasCitizen> spec =
                Specification.allOf(
                        AtlasCitizenSpecification.hasAt(at),
                        AtlasCitizenSpecification.hasFirstName(firstName),
                        AtlasCitizenSpecification.hasLastName(lastName),
                        AtlasCitizenSpecification.hasGender(gender),
                        AtlasCitizenSpecification.hasAfm(afm)
                );

        return repository.findAll(spec);
    }
}