package gr.atlas.registry.service.service;

import gr.atlas.registry.domain.AtlasCitizen;

import java.util.List;

public interface AtlasCitizenService {

    AtlasCitizen createCitizen(AtlasCitizen citizen);

    void deleteCitizen(String at);

    AtlasCitizen updateCitizen(String at, String afm, String address);

    AtlasCitizen getCitizen(String at);

    List<AtlasCitizen> search(
            String at,
            String firstName,
            String lastName,
            String gender,
            String afm
    );
}