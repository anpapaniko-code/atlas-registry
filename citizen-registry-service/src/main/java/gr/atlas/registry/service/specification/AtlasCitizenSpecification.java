package gr.atlas.registry.service.specification;

import gr.atlas.registry.domain.AtlasCitizen;
import org.springframework.data.jpa.domain.Specification;

public class AtlasCitizenSpecification {

    public static Specification<AtlasCitizen> hasAt(String at) {
        return (root, query, cb) ->
                at == null ? null :
                        cb.equal(root.get("at"), at);
    }

    public static Specification<AtlasCitizen> hasFirstName(String firstName) {
        return (root, query, cb) ->
                firstName == null ? null :
                        cb.equal(cb.lower(root.get("firstName")), firstName.toLowerCase());
    }

    public static Specification<AtlasCitizen> hasLastName(String lastName) {
        return (root, query, cb) ->
                lastName == null ? null :
                        cb.equal(cb.lower(root.get("lastName")), lastName.toLowerCase());
    }

    public static Specification<AtlasCitizen> hasGender(String gender) {
        return (root, query, cb) ->
                gender == null ? null :
                        cb.equal(cb.lower(root.get("gender")), gender.toLowerCase());
    }

    public static Specification<AtlasCitizen> hasAfm(String afm) {
        return (root, query, cb) ->
                afm == null ? null :
                        cb.equal(root.get("afm"), afm);
    }
}