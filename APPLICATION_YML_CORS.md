# Add This to Your Gateway's application.yml

Add this CORS configuration to your Gateway's `application.yml` file:

```yaml
spring:
  cloud:
    gateway:
      globalcors:
        cors-configurations:
          '[/**]':
            allowedOriginPatterns: "*"
            allowedMethods:
              - GET
              - POST
              - PUT
              - DELETE
              - OPTIONS
              - PATCH
            allowedHeaders: "*"
            allowCredentials: true
            maxAge: 3600
```

**Location:** `src/main/resources/application.yml` in your Gateway project

This works together with the Java configuration class.

