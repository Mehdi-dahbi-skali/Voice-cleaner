# Quick CORS Fix for Spring Boot Backend

## Problem
Flutter web app cannot connect to Spring Boot backend due to CORS (Cross-Origin Resource Sharing) restrictions.

## Solution 1: Add @CrossOrigin to Your Controller (Easiest)

Add `@CrossOrigin` annotation to your login controller method:

```java
@RestController
@RequestMapping("/userservice/users")
public class UserController {
    
    @PostMapping("/login")
    @CrossOrigin(origins = "*")  // Add this line
    public ResponseEntity<User> login(@RequestBody LoginRequest request) {
        // Your login logic here
        return ResponseEntity.ok(user);
    }
}
```

## Solution 2: Global CORS Configuration (Recommended)

Create a new configuration class in your Spring Boot project:

**File: `src/main/java/com/yourpackage/config/CorsConfig.java`**

```java
package com.yourpackage.config; // Change to your package name

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

@Configuration
public class CorsConfig {

    @Bean
    public CorsFilter corsFilter() {
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        CorsConfiguration config = new CorsConfiguration();
        
        // Allow all origins (for development)
        config.setAllowCredentials(true);
        config.addAllowedOriginPattern("*");
        
        // Allow all headers
        config.addAllowedHeader("*");
        
        // Allow all HTTP methods
        config.addAllowedMethod("*");
        
        // Apply to all endpoints
        source.registerCorsConfiguration("/**", config);
        return new CorsFilter(source);
    }
}
```

## Solution 3: If Using Spring Security

If you're using Spring Security, add this to your SecurityConfig:

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .cors().and()  // Enable CORS
            .csrf().disable()  // Disable CSRF for API
            .authorizeHttpRequests()
            .requestMatchers("/userservice/**").permitAll()
            .anyRequest().authenticated();
        
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

## After Adding CORS

1. **Restart your Spring Boot server**
2. **Clear browser cache** (Ctrl+Shift+Delete)
3. **Try logging in again**

## Alternative: Test on Android (No CORS Issues)

If you want to test immediately without CORS:

```bash
# Run on Android emulator
flutter run -d android

# Update app_config.dart for Android emulator:
# Change: http://localhost:8085
# To:     http://10.0.2.2:8085
```

## Quick Test

After adding CORS, test your endpoint with curl:

```bash
curl -X POST http://localhost:8085/userservice/users/login \
  -H "Content-Type: application/json" \
  -d '{"email":"mds.skali@gmail.com","password":"abcd1234"}'
```

If this works but Flutter web doesn't, the CORS headers might not be set correctly.

