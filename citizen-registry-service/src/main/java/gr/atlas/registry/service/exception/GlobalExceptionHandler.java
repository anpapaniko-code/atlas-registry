package gr.atlas.registry.service.exception;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(CitizenNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(
            CitizenNotFoundException ex,
            HttpServletRequest request) {

        return buildResponse(ex.getMessage(),
                HttpStatus.NOT_FOUND,
                request,
                null);
    }

    @ExceptionHandler(CitizenAlreadyExistsException.class)
    public ResponseEntity<ErrorResponse> handleConflict(
            CitizenAlreadyExistsException ex,
            HttpServletRequest request) {

        return buildResponse(ex.getMessage(),
                HttpStatus.CONFLICT,
                request,
                null);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(
            MethodArgumentNotValidException ex,
            HttpServletRequest request) {

        List<String> errors = ex.getBindingResult()
                .getFieldErrors()
                .stream()
                .map(FieldError::getDefaultMessage)
                .collect(Collectors.toList());

        return buildResponse("Validation failed",
                HttpStatus.BAD_REQUEST,
                request,
                errors);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneric(
            Exception ex,
            HttpServletRequest request) {

        return buildResponse("Internal server error",
                HttpStatus.INTERNAL_SERVER_ERROR,
                request,
                null);
    }

    private ResponseEntity<ErrorResponse> buildResponse(
            String message,
            HttpStatus status,
            HttpServletRequest request,
            List<String> validationErrors) {

        ErrorResponse error = new ErrorResponse(
                LocalDateTime.now(),
                status.value(),
                status.getReasonPhrase(),
                message,
                request.getRequestURI(),
                validationErrors
        );

        return new ResponseEntity<>(error, status);
    }
}