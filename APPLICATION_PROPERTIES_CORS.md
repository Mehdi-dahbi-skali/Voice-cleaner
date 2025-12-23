# CORS Configuration for application.properties

If you're using `application.properties` instead of `application.yml`, add this:

```properties
spring.cloud.gateway.globalcors.cors-configurations.[/**].allowed-origin-patterns=*
spring.cloud.gateway.globalcors.cors-configurations.[/**].allowed-methods=GET,POST,PUT,DELETE,OPTIONS,PATCH
spring.cloud.gateway.globalcors.cors-configurations.[/**].allowed-headers=*
spring.cloud.gateway.globalcors.cors-configurations.[/**].allow-credentials=true
spring.cloud.gateway.globalcors.cors-configurations.[/**].max-age=3600
```

**Location:** `src/main/resources/application.properties` in your Gateway project

## OR Create application.yml

Alternatively, you can create a new `application.yml` file in `src/main/resources/` with:

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

**Note:** If you have both `application.properties` and `application.yml`, Spring Boot will use `application.yml` first.

