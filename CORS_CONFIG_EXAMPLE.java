// Add this configuration class to your Spring Boot backend
// This allows Flutter web app to make requests to your backend

package com.example.config; // Adjust package name

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
        
        // Allow all origins (for development only)
        // In production, specify your Flutter web app URL
        config.setAllowCredentials(true);
        config.addAllowedOriginPattern("*"); // For development
        // For production, use: config.addAllowedOrigin("https://your-flutter-app.com");
        
        // Allow all headers
        config.addAllowedHeader("*");
        
        // Allow all HTTP methods
        config.addAllowedMethod("*");
        
        source.registerCorsConfiguration("/**", config);
        return new CorsFilter(source);
    }
}

// OR if you're using Spring Security, add this to your SecurityConfig:

/*
@Override
protected void configure(HttpSecurity http) throws Exception {
    http.cors().and()
        .csrf().disable()
        // ... other configurations
}
*/

