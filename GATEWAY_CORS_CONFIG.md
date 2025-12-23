# CORS Configuration for Spring Cloud Gateway

Since you're using Eureka with an API Gateway, you need to configure CORS at the **Gateway level**, not just in individual services.

## Option 1: Add CORS Filter to Gateway (Recommended)

Create a CORS configuration class in your **Gateway Service**:

**File:** `src/main/java/com/yourpackage/gateway/config/CorsConfig.java`

```java
package com.yourpackage.gateway.config; // Adjust package name

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.reactive.CorsWebFilter;
import org.springframework.web.cors.reactive.UrlBasedCorsConfigurationSource;

@Configuration
public class CorsConfig {

    @Bean
    public CorsWebFilter corsWebFilter() {
        CorsConfiguration corsConfig = new CorsConfiguration();
        
        // Allow all origins (for development)
        corsConfig.addAllowedOriginPattern("*");
        
        // Allow all headers
        corsConfig.addAllowedHeader("*");
        
        // Allow all HTTP methods
        corsConfig.addAllowedMethod("*");
        
        // Allow credentials
        corsConfig.setAllowCredentials(true);
        
        // Apply to all routes
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", corsConfig);
        
        return new CorsWebFilter(source);
    }
}
```

## Option 2: Add CORS to Gateway Routes Configuration

If you're using `application.yml` or `application.properties` for gateway routes, you can also add CORS in your gateway configuration:

**application.yml:**
```yaml
spring:
  cloud:
    gateway:
      globalcors:
        cors-configurations:
          '[/**]':
            allowedOrigins: "*"
            allowedMethods:
              - GET
              - POST
              - PUT
              - DELETE
              - OPTIONS
            allowedHeaders: "*"
            allowCredentials: true
```

## Option 3: If Using Spring Security in Gateway

If your gateway uses Spring Security, add this to your SecurityConfig:

```java
@Configuration
@EnableWebFluxSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
        http
            .cors().and()
            .csrf().disable()
            .authorizeExchange()
            .anyExchange().permitAll();
        
        return http.build();
    }
    
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(Arrays.asList("*"));
        configuration.setAllowedMethods(Arrays.asList("*"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setAllowCredentials(true);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
```

## Important Notes:

1. **Gateway is the entry point** - All requests go through the gateway first
2. **Remove CORS from UserService** - You can remove `@CrossOrigin` from UserController since gateway will handle it
3. **Restart Gateway** - After adding CORS config, restart your gateway service
4. **Test** - Try logging in from Flutter web app again

## Your Current Setup:

- Gateway route: `/userservice` → routes to UserService
- UserService endpoint: `/users/login`
- Full path: `http://localhost:8085/userservice/users/login`

The gateway receives the request first, so it must handle CORS!

