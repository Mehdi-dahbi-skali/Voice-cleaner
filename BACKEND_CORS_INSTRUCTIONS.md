# Fix CORS in Your Spring Boot Backend

## Quick Fix (30 seconds)

Add this ONE line to your login controller method:

```java
@PostMapping("/login")
@CrossOrigin(origins = "*")  // ← ADD THIS LINE
public ResponseEntity<User> login(@RequestBody LoginRequest request) {
    // Your existing login code
    return ResponseEntity.ok(user);
}
```

**Don't forget to:**
1. Import: `import org.springframework.web.bind.annotation.CrossOrigin;`
2. Restart your Spring Boot server
3. Try logging in again from Flutter web

## That's it! Your Flutter web app will now work.

---

## Alternative: Global CORS Configuration

If you want to enable CORS for all endpoints, create this file:

**File:** `src/main/java/com/yourpackage/config/CorsConfig.java`

```java
package com.yourpackage.config; // Change to your package

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
        config.setAllowCredentials(true);
        config.addAllowedOriginPattern("*");
        config.addAllowedHeader("*");
        config.addAllowedMethod("*");
        source.registerCorsConfiguration("/**", config);
        return new CorsFilter(source);
    }
}
```

Then restart your server.

