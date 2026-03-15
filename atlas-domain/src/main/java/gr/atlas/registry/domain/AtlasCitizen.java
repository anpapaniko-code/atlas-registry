package gr.atlas.registry.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;
import java.util.Objects;

@Entity
@Table(name = "citizens")
public class AtlasCitizen {

    @Id
    @Column(name = "at", length = 8, nullable = false, unique = true)
    @Size(min = 8, max = 8)
    @NotBlank
    private String at;

    @Column(name = "first_name", nullable = false)
    @NotBlank
    private String firstName;

    @Column(name = "last_name", nullable = false)
    @NotBlank
    private String lastName;

    @Column(name = "gender", nullable = false)
    @NotBlank
    private String gender;

    @Column(name = "birth_date", nullable = false)
    @NotNull
    @JsonFormat(pattern = "dd-MM-yyyy")   // 👈 important
    private LocalDate birthDate;

    @Column(name = "afm", length = 9)
    @Pattern(regexp = "\\d{9}")
    private String afm;

    @Column(name = "address")
    private String address;

    public AtlasCitizen() {}

    public AtlasCitizen(String at,
                        String firstName,
                        String lastName,
                        String gender,
                        LocalDate birthDate,
                        String afm,
                        String address) {
        this.at = at;
        this.firstName = firstName;
        this.lastName = lastName;
        this.gender = gender;
        this.birthDate = birthDate;
        this.afm = afm;
        this.address = address;
    }

    // Getters & Setters

    public String getAt() { return at; }
    public void setAt(String at) { this.at = at; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public LocalDate getBirthDate() { return birthDate; }
    public void setBirthDate(LocalDate birthDate) { this.birthDate = birthDate; }

    public String getAfm() { return afm; }
    public void setAfm(String afm) { this.afm = afm; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof AtlasCitizen)) return false;
        AtlasCitizen that = (AtlasCitizen) o;
        return Objects.equals(at, that.at);
    }

    @Override
    public int hashCode() {
        return Objects.hash(at);
    }
}