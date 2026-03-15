package gr.atlas.registry.service;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.junit.jupiter.api.*;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class AtlasCitizenTest {

    @LocalServerPort
    private int port;

    private static final String AT = "87654321";

    @BeforeAll
    static void setup() {
        RestAssured.baseURI = "http://localhost";
    }

    @BeforeEach
    void setPort() {
        RestAssured.port = port;
    }

    @Test
    @Order(1)
    void testCreateCitizen() {

        String json = """
                {
                  "at": "87654321",
                  "firstName": "Maria",
                  "lastName": "Papadopoulou",
                  "gender": "FEMALE",
                  "birthDate": "12-11-2000",
                  "afm": "123456789",
                  "address": "Athens"
                }
                """;

        given()
                .contentType(ContentType.JSON)
                .body(json)
                .post("/api/citizens")
                .then()
                .statusCode(201)
                .header("Location", containsString("/api/citizens/" + AT));
    }

    @Test
    @Order(2)
    void testCreateDuplicateShouldReturn409() {

        String json = """
                {
                  "at": "87654321",
                  "firstName": "Maria",
                  "lastName": "Papadopoulou",
                  "gender": "FEMALE",
                  "birthDate": "12-11-2000",
                  "afm": "123456789",
                  "address": "Athens"
                }
                """;

        given()
                .contentType(ContentType.JSON)
                .body(json)
                .post("/api/citizens")
                .then()
                .statusCode(409);
    }

    @Test
    @Order(3)
    void testGetCitizen() {

        given()
                .get("/api/citizens/" + AT)
                .then()
                .statusCode(200)
                .body("firstName", equalTo("Maria"));
    }

    @Test
    @Order(4)
    void testUpdateCitizen() {

        String json = """
                {
                  "afm": "999999999",
                  "address": "Thessaloniki"
                }
                """;

        given()
                .contentType(ContentType.JSON)
                .body(json)
                .put("/api/citizens/" + AT)
                .then()
                .statusCode(200)
                .body("afm", equalTo("999999999"));
    }

    @Test
    @Order(5)
    void testUpdateInvalidAfmShouldReturn400() {

        String json = """
                {
                  "afm": "123"
                }
                """;

        given()
                .contentType(ContentType.JSON)
                .body(json)
                .put("/api/citizens/" + AT)
                .then()
                .statusCode(400);
    }

    @Test
    @Order(6)
    void testSearchByFirstName() {

        given()
                .queryParam("firstName", "Maria")
                .get("/api/citizens")
                .then()
                .statusCode(200)
                .body("size()", greaterThanOrEqualTo(1));
    }

    @Test
    @Order(7)
    void testDeleteCitizen() {

        given()
                .delete("/api/citizens/" + AT)
                .then()
                .statusCode(204);
    }

    @Test
    @Order(8)
    void testDeleteNonExistingShouldReturn404() {

        given()
                .delete("/api/citizens/00000000")
                .then()
                .statusCode(404);
    }
}