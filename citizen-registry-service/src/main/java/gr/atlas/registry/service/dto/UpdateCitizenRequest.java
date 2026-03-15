package gr.atlas.registry.service.dto;

import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class UpdateCitizenRequest {

    @Pattern(regexp = "\\d{9}", message = "AFM must contain exactly 9 digits")
    private String afm;

    @Size(max = 255, message = "Address too long")
    private String address;

    public String getAfm() {
        return afm;
    }

    public void setAfm(String afm) {
        this.afm = afm;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }
}