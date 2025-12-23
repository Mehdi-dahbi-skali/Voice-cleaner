# Complete CORS Fix for Spring Cloud Gateway

## Issue: CORS still not working

Since you're using Spring Cloud Gateway (reactive), you might need additional configuration.

## Solution 1: Enhanced CORS Config (Try This First)

Update your `CorsConfig.java` in the Gateway:

```java
package emsi.projet.apigateway.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.reactive.CorsWebFilter;
import org.springframework.web.cors.reactive.UrlBasedCorsConfigurationSource;
import org.springframework.web.reactive.config.CorsRegistry;
import org.springframework.web.reactive.config.WebFluxConfigurer;

@Configuration
public class CorsConfig implements WebFluxConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOriginPatterns("*")
                .allowedMethods("*")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }

    @Bean
    public CorsWebFilter corsWebFilter() {
        CorsConfiguration corsConfig = new CorsConfiguration();
        corsConfig.setAllowCredentials(true);
        corsConfig.addAllowedOriginPattern("*");
        corsConfig.addAllowedHeader("*");
        corsConfig.addAllowedMethod("*");
        corsConfig.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", corsConfig);

        return new CorsWebFilter(source);
    }
}
```

**Important:** Make sure to add this import:
```java
import org.springframework.web.reactive.config.WebFluxConfigurer;
import org.springframework.web.reactive.config.CorsRegistry;
```

## Solution 2: Add to application.yml

Also add this to your Gateway's `application.yml`:

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

## Solution 3: If Using Spring Security

If your Gateway uses Spring Security, you might need to disable CSRF:

```java
@Configuration
@EnableWebFluxSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityWebFilterChain securityWebFilterChain(ServerHttpSecurity http) {
        return http
            .csrf().disable()
            .cors().and()
            .authorizeExchange()
            .anyExchange().permitAll()
            .and()
            .build();
    }
}
```

## Verification Steps:

1. **Restart Gateway** - Stop and start your Gateway service
2. **Check Logs** - Look for any CORS-related errors
3. **Test with curl** - Test the endpoint:
   ```bash
   curl -X OPTIONS http://localhost:8085/userservice/users/login \
     -H "Origin: http://localhost" \
     -H "Access-Control-Request-Method: POST" \
     -v
   ```
   You should see CORS headers in the response.

4. **Check Browser Network Tab**:
   - Open Chrome DevTools (F12)
   - Go to Network tab
   - Try to login
   - Check the request headers and response headers
   - Look for `Access-Control-Allow-Origin` in response headers

## Common Issues:

1. **Package not scanned**: Make sure `CorsConfig` is in `emsi.projet.apigateway.config` (which it is)
2. **Gateway not restarted**: Must restart after adding config
3. **Multiple CORS configs**: Remove any duplicate CORS configurations
4. **Spring Security blocking**: If using Spring Security, configure it properly

## Quick Test:

After restarting, check if CORS headers are present:
```bash
curl -I -X OPTIONS http://localhost:8085/userservice/users/login \
  -H "Origin: http://localhost" \
  -H "Access-Control-Request-Method: POST"
```

You should see:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: *
Access-Control-Allow-Headers: *
```

