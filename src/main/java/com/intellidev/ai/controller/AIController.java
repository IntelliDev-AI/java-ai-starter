package com.intellidev.ai.controller;

import com.intellidev.ai.service.AIService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/ai")
@RequiredArgsConstructor
@Slf4j
public class AIController {
    
    private final AIService aiService;
    
    /**
     * AI对话接口
     */
    @PostMapping("/chat")
    public ResponseEntity<Map<String, Object>> chat(@RequestBody ChatRequest request) {
        log.info("收到AI对话请求: {}", request.getMessage());
        
        Map<String, Object> response = new HashMap<>();
        
        if (!aiService.isAvailable()) {
            response.put("success", false);
            response.put("error", "AI服务未配置，请设置OPENAI_API_KEY");
            return ResponseEntity.badRequest().body(response);
        }
        
        try {
            String answer = aiService.chat(request.getMessage());
            
            response.put("success", true);
            response.put("message", request.getMessage());
            response.put("answer", answer);
            response.put("model", aiService.getModel());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("AI对话失败", e);
            response.put("success", false);
            response.put("error", e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 代码审查接口
     */
    @PostMapping("/review-code")
    public ResponseEntity<Map<String, Object>> reviewCode(@RequestBody CodeReviewRequest request) {
        log.info("收到代码审查请求，语言: {}", request.getLanguage());
        
        Map<String, Object> response = new HashMap<>();
        
        if (!aiService.isAvailable()) {
            response.put("success", false);
            response.put("error", "AI服务未配置");
            return ResponseEntity.badRequest().body(response);
        }
        
        try {
            String review = aiService.reviewCode(request.getCode(), request.getLanguage());
            
            response.put("success", true);
            response.put("language", request.getLanguage());
            response.put("code", request.getCode());
            response.put("review", review);
            response.put("model", aiService.getModel());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("代码审查失败", e);
            response.put("success", false);
            response.put("error", e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 生成代码文档接口
     */
    @PostMapping("/generate-docs")
    public ResponseEntity<Map<String, Object>> generateDocumentation(@RequestBody CodeDocRequest request) {
        log.info("收到生成文档请求，语言: {}", request.getLanguage());
        
        Map<String, Object> response = new HashMap<>();
        
        if (!aiService.isAvailable()) {
            response.put("success", false);
            response.put("error", "AI服务未配置");
            return ResponseEntity.badRequest().body(response);
        }
        
        try {
            String documentation = aiService.generateDocumentation(request.getCode(), request.getLanguage());
            
            response.put("success", true);
            response.put("language", request.getLanguage());
            response.put("code", request.getCode());
            response.put("documentation", documentation);
            response.put("model", aiService.getModel());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("生成文档失败", e);
            response.put("success", false);
            response.put("error", e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 检查AI服务状态
     */
    @GetMapping("/status")
    public ResponseEntity<Map<String, Object>> getStatus() {
        Map<String, Object> response = new HashMap<>();
        response.put("service", "Java AI Starter");
        response.put("version", "0.0.1");
        response.put("ai_available", aiService.isAvailable());
        response.put("ai_model", aiService.isAvailable() ? aiService.getModel() : "未配置");
        response.put("timestamp", System.currentTimeMillis());
        return ResponseEntity.ok(response);
    }
    
    // 请求DTO类
    public static class ChatRequest {
        private String message;
        
        public String getMessage() {
            return message;
        }
        
        public void setMessage(String message) {
            this.message = message;
        }
    }
    
    public static class CodeReviewRequest {
        private String code;
        private String language;
        
        public String getCode() {
            return code;
        }
        
        public void setCode(String code) {
            this.code = code;
        }
        
        public String getLanguage() {
            return language;
        }
        
        public void setLanguage(String language) {
            this.language = language;
        }
    }
    
    public static class CodeDocRequest {
        private String code;
        private String language;
        
        public String getCode() {
            return code;
        }
        
        public void setCode(String code) {
            this.code = code;
        }
        
        public String getLanguage() {
            return language;
        }
        
        public void setLanguage(String language) {
            this.language = language;
        }
    }
}