package gr.atlas.registry.service.exception;

public class CitizenNotFoundException extends RuntimeException {

    public CitizenNotFoundException(String at) {
        super("Citizen with AT " + at + " not found");
    }
}