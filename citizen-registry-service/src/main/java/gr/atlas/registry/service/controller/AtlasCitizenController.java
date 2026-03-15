package gr.atlas.registry.service.controller;

import gr.atlas.registry.domain.AtlasCitizen;
import gr.atlas.registry.service.dto.UpdateCitizenRequest;
import gr.atlas.registry.service.service.AtlasCitizenService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/api/citizens")
public class AtlasCitizenController {

    private final AtlasCitizenService service;

    public AtlasCitizenController(AtlasCitizenService service) {
        this.service = service;
    }

    // CREATE → 201
    @PostMapping
    public ResponseEntity<AtlasCitizen> create(
            @Valid @RequestBody AtlasCitizen citizen) {

        AtlasCitizen created = service.createCitizen(citizen);

        URI location = URI.create("/api/citizens/" + created.getAt());

        return ResponseEntity
                .created(location)
                .body(created);
    }

    // DELETE
    @DeleteMapping("/{at}")
    public ResponseEntity<Void> delete(@PathVariable String at) {
        service.deleteCitizen(at);
        return ResponseEntity.noContent().build();
    }

    // UPDATE (validated JSON body)
    @PutMapping("/{at}")
    public ResponseEntity<AtlasCitizen> update(
            @PathVariable String at,
            @Valid @RequestBody UpdateCitizenRequest request) {

        AtlasCitizen updated =
                service.updateCitizen(at, request.getAfm(), request.getAddress());

        return ResponseEntity.ok(updated);
    }

    // DISPLAY
    @GetMapping("/{at}")
    public ResponseEntity<AtlasCitizen> get(@PathVariable String at) {
        return ResponseEntity.ok(service.getCitizen(at));
    }

    // SEARCH
    @GetMapping
    public ResponseEntity<List<AtlasCitizen>> search(
            @RequestParam(required = false) String at,
            @RequestParam(required = false) String firstName,
            @RequestParam(required = false) String lastName,
            @RequestParam(required = false) String gender,
            @RequestParam(required = false) String afm) {

        return ResponseEntity.ok(
                service.search(at, firstName, lastName, gender, afm)
        );
    }
}