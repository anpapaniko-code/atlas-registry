package gr.atlas.registry.domain;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

class AtlasCitizenEntityTest {

    private static Validator validator;

    @BeforeAll
    static void setupValidator() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    @Test
    void shouldCreateValidCitizen() {

        AtlasCitizen citizen = new AtlasCitizen(
                "12345678",
                "John",
                "Doe",
                "MALE",
                LocalDate.of(2000, 11, 12),
                "123456789",
                "Athens"
        );

        Set<ConstraintViolation<AtlasCitizen>> violations =
                validator.validate(citizen);

        assertTrue(violations.isEmpty());
        assertEquals("12345678", citizen.getAt());
        assertEquals("John", citizen.getFirstName());
    }

    @Test
    void shouldFailWhenATInvalid() {

        AtlasCitizen citizen = new AtlasCitizen(
                "123",  // invalid AT
                "John",
                "Doe",
                "MALE",
                LocalDate.of(2000, 11, 12),
                "123456789",
                "Athens"
        );

        Set<ConstraintViolation<AtlasCitizen>> violations =
                validator.validate(citizen);

        assertFalse(violations.isEmpty());
    }

    @Test
    void shouldFailWhenAFMInvalid() {

        AtlasCitizen citizen = new AtlasCitizen(
                "12345678",
                "John",
                "Doe",
                "MALE",
                LocalDate.of(2000, 11, 12),
                "123",   // invalid AFM
                "Athens"
        );

        Set<ConstraintViolation<AtlasCitizen>> violations =
                validator.validate(citizen);

        assertFalse(violations.isEmpty());
    }

    @Test
    void shouldFailWhenBirthDateNull() {

        AtlasCitizen citizen = new AtlasCitizen(
                "12345678",
                "John",
                "Doe",
                "MALE",
                null,   // invalid
                "123456789",
                "Athens"
        );

        Set<ConstraintViolation<AtlasCitizen>> violations =
                validator.validate(citizen);

        assertFalse(violations.isEmpty());
    }

    @Test
    void equalsShouldBeBasedOnATOnly() {

        AtlasCitizen c1 = new AtlasCitizen(
                "11111111",
                "A",
                "B",
                "MALE",
                LocalDate.now(),
                null,
                null
        );

        AtlasCitizen c2 = new AtlasCitizen(
                "11111111",
                "X",
                "Y",
                "FEMALE",
                LocalDate.now(),
                null,
                null
        );

        assertEquals(c1, c2);
        assertEquals(c1.hashCode(), c2.hashCode());
    }
}