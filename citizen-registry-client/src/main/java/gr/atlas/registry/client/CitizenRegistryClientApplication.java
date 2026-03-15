package gr.atlas.registry.client;

import gr.atlas.registry.domain.AtlasCitizen;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;
import java.util.Scanner;

@SpringBootApplication
public class CitizenRegistryClientApplication implements CommandLineRunner {

    private final RestTemplate restTemplate = new RestTemplate();
    private final Scanner scanner = new Scanner(System.in);

    private static final String BASE_URL = "http://localhost:8080/api/citizens";
    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy");

    public static void main(String[] args) {
        SpringApplication.run(CitizenRegistryClientApplication.class, args);
    }

    @Override
    public void run(String... args) {

        while (true) {
            System.out.println("\n=== Citizen Registry Menu ===");
            System.out.println("1. Create Citizen");
            System.out.println("2. Get Citizen by AT");
            System.out.println("3. Update Citizen");
            System.out.println("4. Delete Citizen");
            System.out.println("5. Search Citizens");
            System.out.println("0. Exit");
            System.out.print("Choose option: ");

            String choice = scanner.nextLine();

            switch (choice) {
                case "1" -> createCitizen();
                case "2" -> getCitizen();
                case "3" -> updateCitizen();
                case "4" -> deleteCitizen();
                case "5" -> searchCitizens();
                case "0" -> {
                    System.out.println("Exiting...");
                    return;
                }
                default -> {
                    System.out.println("Invalid option. Exiting...");
                    return;
                }
            }
        }
    }

    private void createCitizen() {
        try {
            System.out.print("AT (8 chars): ");
            String at = scanner.nextLine();

            System.out.print("First Name: ");
            String firstName = scanner.nextLine();

            System.out.print("Last Name: ");
            String lastName = scanner.nextLine();

            System.out.print("Gender: ");
            String gender = scanner.nextLine();

            System.out.print("Birth Date (dd-MM-yyyy): ");
            LocalDate birthDate = LocalDate.parse(scanner.nextLine(), formatter);

            System.out.print("AFM (optional): ");
            String afm = scanner.nextLine();

            System.out.print("Address (optional): ");
            String address = scanner.nextLine();

            AtlasCitizen citizen = new AtlasCitizen(
                    at, firstName, lastName, gender, birthDate, afm, address
            );

            ResponseEntity<AtlasCitizen> response =
                    restTemplate.postForEntity(BASE_URL, citizen, AtlasCitizen.class);

            System.out.println("Created: " + response.getBody());

        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    private void getCitizen() {
        try {
            System.out.print("Enter AT: ");
            String at = scanner.nextLine();

            AtlasCitizen citizen =
                    restTemplate.getForObject(BASE_URL + "/" + at, AtlasCitizen.class);

            System.out.println("Found: " + citizen);

        } catch (Exception e) {
            System.out.println("Error: Citizen not found.");
        }
    }

    private void updateCitizen() {
        try {
            System.out.print("Enter AT: ");
            String at = scanner.nextLine();

            System.out.print("New AFM: ");
            String afm = scanner.nextLine();

            System.out.print("New Address: ");
            String address = scanner.nextLine();

            restTemplate.put(BASE_URL + "/" + at + "?afm=" + afm + "&address=" + address, null);

            System.out.println("Updated successfully.");

        } catch (Exception e) {
            System.out.println("Error updating citizen.");
        }
    }

    private void deleteCitizen() {
        try {
            System.out.print("Enter AT: ");
            String at = scanner.nextLine();

            restTemplate.delete(BASE_URL + "/" + at);

            System.out.println("Deleted successfully.");

        } catch (Exception e) {
            System.out.println("Error deleting citizen.");
        }
    }

    private void searchCitizens() {
        try {
            System.out.print("First Name (optional): ");
            String firstName = scanner.nextLine();

            System.out.print("Last Name (optional): ");
            String lastName = scanner.nextLine();

            String url = BASE_URL + "/search?firstName=" + firstName + "&lastName=" + lastName;

            AtlasCitizen[] results =
                    restTemplate.getForObject(url, AtlasCitizen[].class);

            List<AtlasCitizen> list = Arrays.asList(results);
            list.forEach(System.out::println);

        } catch (Exception e) {
            System.out.println("Error searching citizens.");
        }
    }
}