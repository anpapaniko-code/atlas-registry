package gr.atlas.registry.service.exception;

public class CitizenAlreadyExistsException extends RuntimeException {

    public CitizenAlreadyExistsException(String at) {
        super("Citizen with AT " + at + " already exists");
    }
}